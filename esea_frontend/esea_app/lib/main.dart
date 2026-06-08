import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_sso_screen.dart';
import 'screens/home/app_shell.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'config/theme.dart';

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
    isStudent: false, // change after login
  );

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      options.tracesSampleRate = 1.0;
      options.environment = const String.fromEnvironment('SENTRY_ENV', defaultValue: 'production');
      options.sendDefaultPii = false; // Disable sensitive PII collection
    },
    appRunner: () => runApp(const EseaApp()),
  );
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
        theme: AppTheme.lightTheme,
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

    if (!auth.isInitialized) {
      return const AnimatedSplashScreen();
    }

    if (!auth.isAuthenticated) {
      return const LoginSSOScreen();
    }

    return const AppShell();
  }
}