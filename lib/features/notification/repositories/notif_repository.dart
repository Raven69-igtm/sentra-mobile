import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentra/core/network/api_client.dart';

class NotificationRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://${ApiClient.baseUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
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

  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return Stream.periodic(Duration(seconds: 5), (_) async {
      try {
        final response = await _dio.get('/notifications', queryParameters: {
          'user_id': userId,
        });
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          return data.map((item) => {
                'id': item['id_notif'].toString(),
                'title': item['judul'],
                'message': item['pesan'],
                'type': item['tipe'],
                'status': item['status'] == 'terkirim' ? false : true,
                'date': item['created_at'],
                'id_akun': item['id_akun'].toString(),
              }).toList();
        } else {
          throw Exception('Gagal memuat notifikasi: ${response.statusCode} - ${response.data}');
        }
      } catch (e) {
        throw Exception('Gagal memuat notifikasi: $e');
      }
    }).asyncExpand((event) => Stream.fromFuture(event));
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

  Future<void> restoreNotification(Map<String, dynamic> notification) async {
    try {
      final response = await _dio.post(
        '/notifications/restore',
        data: {
          'id_notif': notification['id'],
          'id_akun': notification['id_akun'],
          'judul': notification['title'],
          'pesan': notification['message'],
          'tipe': notification['type'],
          'status': notification['status'] ? 'dibaca' : 'terkirim',
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
      final response = await _dio.patch(
        '/notifications/$id/read',
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
      final response = await _dio.delete('/notifications/$id');
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus notifikasi: $e');
    }
  }
}
