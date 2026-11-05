import 'package:sentra/features/notification/repositories/notif_repository.dart';
import 'package:rxdart/rxdart.dart';

class NotificationController {
  final NotificationRepository _repository = NotificationRepository();
  final BehaviorSubject<List<Map<String, dynamic>>> _notificationsSubject =
      BehaviorSubject<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>> get notificationStream =>
      _notificationsSubject.stream;

  NotificationController(String userId) {
    _repository
        .getNotifications(userId)
        .listen(
          (notifications) {
            _notificationsSubject.add(notifications);
          },
          onError: (error) {
            _notificationsSubject.addError(error);
          },
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
    _notificationsSubject.close();
  }
}
