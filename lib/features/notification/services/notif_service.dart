import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'sentra_channel',
        channelName: 'Sentra Notifications',
        channelDescription: 'Notification channel for Sentra app',
        defaultColor: const Color(0xFF9D50BB),
        ledColor: Colors.white,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        importance: NotificationImportance.High,
      ),
    ], debug: true);

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'sentra_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
    );
  }
}
