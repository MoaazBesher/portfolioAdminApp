import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/data_provider.dart';
import 'services/firebase_service.dart';
import 'ui/auth/login_screen.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'messages_page.dart';
import 'admin_notifications_service.dart';

/// Global navigator key — required so [AdminNotificationsService] can push
/// routes from background / terminated notification taps without a [BuildContext].
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialise FCM: registers the background handler and saves the token.
  // Must be called after Firebase.initializeApp().
  await AdminNotificationsService.instance.initialize(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const PortfolioAdminApp(),
    ),
  );
}

class PortfolioAdminApp extends StatelessWidget {
  const PortfolioAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio Admin',
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/messages': (context) => const MessagesPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService().currentUser != null
          ? Stream.value(FirebaseService().currentUser)
          : const Stream.empty(),
      builder: (context, snapshot) {
        if (FirebaseService().currentUser != null) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
