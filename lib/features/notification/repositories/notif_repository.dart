import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/network/endpoints.dart';

class NotificationRepository {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final List<Map<String, dynamic>> _localNotifications = [];
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  bool _disposed = false;

  NotificationRepository() {
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      await _fcm.requestPermission();

      _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleNotification(message);
      });

      _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) {
        _handleNotification(message);
      });
    } catch (e) {
      debugPrint('FCM init error (non-fatal): $e');
    }
  }

  void dispose() {
    _disposed = true;
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();
    _onMessageSub = null;
    _onMessageOpenedSub = null;
  }

  Future<void> updateFCMToken(int? userId, String? fcmToken) async {
    if (fcmToken == null || fcmToken.isEmpty) return;
    try {
      await ApiClient.postRequest(Endpoints.updateFcmToken, {
        if (userId != null) 'user_id': userId,
        'fcm_token': fcmToken,
      });
    } catch (e) {
      debugPrint('Error updating FCM token (non-fatal): $e');
    }
  }

  void _handleNotification(RemoteMessage message) {
    if (message.notification != null) {
      final notification = {
        'title': message.notification!.title ?? 'Notifikasi Baru',
        'message': message.notification!.body ?? 'Pesan baru diterima',
        'date': DateTime.now().toIso8601String(),
        'id_laporan': message.data['id_laporan']?.toString() ?? '',
        'source':
            message.data['source'] ??
            message.data['module'] ??
            message.data['sumber'] ??
            '',
        'category': message.data['category'] ?? message.data['kategori'] ?? '',
        'type': message.data['type'] ?? message.data['tipe'] ?? '',
        'status': false,
      };
      _localNotifications.insert(0, notification);
    }
  }

  /// Mengambil notifikasi secara berkala melalui [ApiClient] (dengan token Sanctum).
  /// Loop berhenti otomatis saat repository di-dispose atau stream dibatalkan.
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) async* {
    while (!_disposed) {
      bool failed = false;

      try {
        final response = await ApiClient.getRequest(
          Endpoints.notifications,
          params: {'user_id': userId},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data =
              response.data is List
                  ? response.data
                  : (response.data['data'] ?? []);

          final List<Map<String, dynamic>> apiNotifications =
              data
                  .map<Map<String, dynamic>>(
                    (item) => {
                      'id': item['id_notif']?.toString() ?? '',
                      'title': item['judul'] ?? '',
                      'message': item['pesan'] ?? '',
                      'type': item['tipe'] ?? '',
                      'id_laporan': item['id_laporan']?.toString() ?? '',
                      'source':
                          item['source'] ??
                          item['sumber'] ??
                          item['module'] ??
                          item['modul'] ??
                          '',
                      'category':
                          item['category'] ??
                          item['kategori'] ??
                          item['tipe'] ??
                          '',
                      'status': item['status'] == 'terkirim' ? false : true,
                      'date': item['created_at'] ?? '',
                      'id_akun': item['id_akun']?.toString() ?? '',
                    },
                  )
                  .toList();

          final merged = [..._localNotifications, ...apiNotifications];
          yield merged;
        } else {
          yield const <Map<String, dynamic>>[];
        }
      } on ApiException catch (e) {
        debugPrint('Notification fetch error (non-fatal): ${e.message}');
        failed = true;
        yield _localNotifications.isNotEmpty
            ? List.from(_localNotifications)
            : const <Map<String, dynamic>>[];
        if (e.statusCode == 401 || e.statusCode == 403) {
          break;
        }
      } catch (e) {
        debugPrint('Unexpected notification error (non-fatal): $e');
        failed = true;
        yield _localNotifications.isNotEmpty
            ? List.from(_localNotifications)
            : const <Map<String, dynamic>>[];
      }

      if (_disposed) break;
      await Future.delayed(Duration(seconds: failed ? 20 : 10));
    }
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String message,
  ) async {
    try {
      await ApiClient.postRequest(Endpoints.newMessageNotif, {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Gagal mengirim pesan');
    }
  }

  Future<void> sendReportUpdate(
    String idLaporan,
    String userId,
    String status,
  ) async {
    try {
      await ApiClient.postRequest(Endpoints.reportUpdateNotif, {
        'id_laporan': idLaporan,
        'user_id': userId,
        'status': status,
      });
    } catch (e) {
      debugPrint('Error sending report update: $e');
      throw Exception('Gagal mengupdate status laporan');
    }
  }

  Future<void> restoreNotification(Map<String, dynamic> notification) async {
    try {
      final response = await ApiClient.postRequest(
        Endpoints.notificationsRestore,
        {
          'id_notif': notification['id'],
          'id_akun': notification['id_akun'],
          'judul': notification['title'],
          'pesan': notification['message'],
          'tipe': notification['type'],
          'status': notification['status'] == true ? 'dibaca' : 'terkirim',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal memulihkan notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memulihkan notifikasi: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await ApiClient.patchRequest(
        '${Endpoints.notifications}/$id/read',
        data: {'status': 'dibaca'},
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Gagal menandai notifikasi sebagai dibaca: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal menandai notifikasi sebagai dibaca: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await ApiClient.deleteRequest(
        '${Endpoints.notifications}/$id',
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus notifikasi: $e');
    }
  }
}
