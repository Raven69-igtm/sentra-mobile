import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentra/features/notification/repositories/notif_repository.dart';
import 'package:rxdart/rxdart.dart';

class NotificationController {
  final NotificationRepository _repository = NotificationRepository();
  final BehaviorSubject<List<Map<String, dynamic>>> _notificationsSubject =
      BehaviorSubject<List<Map<String, dynamic>>>();
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  Stream<List<Map<String, dynamic>>> get notificationStream =>
      _notificationsSubject.stream;

  NotificationController(String userId) {
    _subscription = _repository
        .getNotifications(userId)
        .listen(
          (notifications) {
            if (!_notificationsSubject.isClosed) {
              _notificationsSubject.add(notifications);
            }
          },
          onError: (error) {
            debugPrint('NotificationController stream error (non-fatal): $error');
            if (!_notificationsSubject.isClosed) {
              _notificationsSubject.add([]);
            }
          },
          cancelOnError: false,
        );
  }

  Future<void> sendNewMessage(
    String senderId,
    String receiverId,
    String message,
  ) async {
    await _repository.sendMessage(senderId, receiverId, message);
  }

  Future<void> sendReportUpdate(
    String idLaporan,
    String userId,
    String status,
  ) async {
    await _repository.sendReportUpdate(idLaporan, userId, status);
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
  }

  Future<void> restoreNotification(Map<String, dynamic> notification) async {
    await _repository.restoreNotification(notification);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _repository.dispose();
    _notificationsSubject.close();
  }
}
