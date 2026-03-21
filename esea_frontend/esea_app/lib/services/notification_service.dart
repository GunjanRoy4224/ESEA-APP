import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../screens/internships/internship_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/announcements/announcements_screen.dart';
import '../screens/newsletter/newsletter_screen.dart';
import '../screens/blogs/research_blog_screen.dart';


class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
  'esea_notifications', // id
  'ESEA Notifications', // name
  description: 'Channel for ESEA app notifications',
  importance: Importance.high,
  );
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // -------------------------------
  // Initialize notifications
  // -------------------------------
  Future<void> initNotifications({required bool isEseaMember}) async {

    // Request notification permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? token = await _messaging.getToken();
    print("FCM TOKEN: $token");
    // Initialize local notifications
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await _localNotifications.initialize(initSettings);

  // Create notification channel
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

    print("Notification permission: ${settings.authorizationStatus}");

    // Subscribe all users
    await _messaging.subscribeToTopic("all_users");
    print("Subscribed to topic: all_users");

    // Subscribe ESEA members
    if (isEseaMember) {
      await _messaging.subscribeToTopic("esea_members");
      print("Subscribed to topic: esea_members");
    }

    // Start listeners
    listenForeground();
  }

  // -------------------------------
  // Foreground notifications
  // -------------------------------
  void listenForeground() {

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

    print("Foreground notification received");

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }

  });
}

    // -------------------------------
  // Notification click handler
  // -------------------------------
  void handleNotificationTap(BuildContext context) {

    // When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(context, message);
    });

    // When app is terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNavigation(context, message);
      }
    });
  }

 void _handleNavigation(BuildContext context, RemoteMessage message) {

  final data = message.data;

  print("Notification tapped: $data");

  final type = data["type"];
  final id = data["id"];

  WidgetsBinding.instance.addPostFrameCallback((_) {

    if (type == "Internship") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const InternshipsScreen(),
        ),
      );
    }

    if (type == "Event") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const EventsScreen(),
        ),
      );
    }

    if (type == "Announcement") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const AnnouncementsScreen(),
        ),
      );
    }

    if (type == "Newsletter") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const NewslettersScreen(),
        ),
      );
    }

    if (type == "Research") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const ResearchScreen(),
        ),
      );
    }

  });
}
}