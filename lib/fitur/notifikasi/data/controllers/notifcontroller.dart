import 'package:sentra/fitur/notifikasi/data/repositories/notifrepositories.dart';
import 'package:rxdart/rxdart.dart';

class NotificationController {
  final NotificationRepository _repository = NotificationRepository();
  final BehaviorSubject<List<Map<String, dynamic>>> _notificationsSubject =
      BehaviorSubject<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>> get notificationStream =>
      _notificationsSubject.stream;

  NotificationController() {
    _repository.getNotifications().listen((notifications) {
      _notificationsSubject.add(notifications);
    });
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

  void dispose() {
    _notificationsSubject.close();
  }
}
