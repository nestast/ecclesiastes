import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Configuration Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuration iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialisation
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Optionnel : Ajouter une logique ici pour naviguer vers une page précise
        // lors du clic sur la notification.
      },
    );

    // Demander les permissions spécifiquement pour Android 13+
    if (Platform.isAndroid) {
      _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({String? title, String? body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ecclesiaste_channel_id', // ID unique du canal
        'Annonces Ecclesiaste',    // Nom visible dans les réglages du téléphone
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      DateTime.now().millisecond, // ID unique pour chaque notification
      title,
      body,
      details,
    );
  }
}