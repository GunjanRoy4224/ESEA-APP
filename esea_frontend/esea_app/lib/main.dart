import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_sso_screen.dart';
import 'screens/home/app_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Background notification handler
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Initialize notifications
  await NotificationService().initNotifications(
    isEseaMember: false, // change after login
  );

  runApp(const EseaApp());
}

class EseaApp extends StatelessWidget {
  const EseaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ESEA Portal',
        home: const AppEntry(),
        navigatorKey: navigatorKey,
      ),
    );
  }
}

/// ENTRY POINT (IMPORTANT)
class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const LoginSSOScreen();
    }

    if (!auth.isAuthenticated) {
      return const LoginSSOScreen();
    }

    return const AppShell();
  }
}