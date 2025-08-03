import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentra/core/network/api_client.dart';

class NotificationRepository {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://${ApiClient.baseUrl}/api'),
  );
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final List<Map<String, dynamic>> _notifications = [];

  NotificationRepository() {
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    await _fcm.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message);
    });
  }

 Future<void> updateFCMToken(int? userId, String? fcmToken) async {
    try {
      await _dio.post(
        '/update-fcm-token',
        data: {'user_id': userId, 'fcm_token': fcmToken ?? ''},
      );
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  void _handleNotification(RemoteMessage message) {
    if (message.notification != null) {
      final notification = {
        'title': message.notification!.title ?? 'Notifikasi Baru',
        'message': message.notification!.body ?? 'Pesan baru diterima',
        'date': DateTime.now().toIso8601String(),
        'id_laporan': message.data['id_laporan']?.toString() ?? '',
        'is_read': false,
      };
      _notifications.insert(0, notification);
    }
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String message,
  ) async {
    try {
      await _dio.post(
        '/new-message',
        data: {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
        },
      );
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Gagal mengirim pesan');
    }
  }

  Future<void> sendReportUpdate(
    String idLaporan,
    String userId,
    String status,
  ) async {
    try {
      await _dio.post(
        '/report-update',
        data: {'id_laporan': idLaporan, 'user_id': userId, 'status': status},
      );
    } catch (e) {
      print('Error sending report update: $e');
      throw Exception('Gagal mengupdate status laporan');
    }
  }

  Stream<List<Map<String, dynamic>>> getNotifications() async* {
    yield _notifications;
    await for (var _ in Stream.periodic(Duration(seconds: 5))) {
      yield _notifications;
    }
  }
}
