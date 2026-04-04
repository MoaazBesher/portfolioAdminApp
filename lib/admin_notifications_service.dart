import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Top-level handler for background/terminated FCM messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this runs.
  debugPrint('[FCM Background] id=${message.messageId} data=${message.data}');
}

class AdminNotificationsService {
  AdminNotificationsService._();
  static final AdminNotificationsService instance = AdminNotificationsService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Call once, very early in [main], before [runApp].
  /// [navigatorKey] is used to push routes when a notification is tapped
  /// while the app is in the terminated or background state.
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    // 1. Register the background handler (idempotent if called multiple times).
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permission (Android 13+ requires this).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // 3. Set foreground notification presentation options (Android shows
    //    heads-up banners; iOS shows alerts/badges/sounds).
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Save the current token and watch for refreshes.
    await _saveToken();
    _fcm.onTokenRefresh.listen((_) => _saveToken());

    // 5. Handle notification taps when the app was TERMINATED.
    final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage, navigatorKey);
    }

    // 6. Handle notification taps when the app was in the BACKGROUND.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageTap(message, navigatorKey);
    });

    // 7. Handle messages received while the app is in the FOREGROUND.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM Foreground] ${message.notification?.title}');
      // Optionally show an in-app SnackBar for foreground messages.
      final context = navigatorKey.currentContext;
      if (context != null && message.notification != null) {
        final title = message.notification!.title ?? 'New Message';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(title),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _handleMessageTap(message, navigatorKey),
            ),
          ),
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  Future<void> _saveToken([String? token]) async {
    try {
      final t = token ?? await _fcm.getToken();
      if (t == null) return;

      // Sanitise: Firebase keys cannot contain "."
      final sanitized = t.replaceAll('.', '_');

      await _db.child('admin_tokens/$sanitized').set({
        'token': t,
        'platform': 'android',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('[FCM] Token saved: $sanitized');
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _handleMessageTap(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final data = message.data;
    final String? messageId = data['messageId'] as String?;

    // Small delay to ensure the widget tree is mounted before pushing.
    Future.delayed(const Duration(milliseconds: 300), () {
      navigatorKey.currentState?.pushNamed(
        '/messages',
        arguments: {'messageId': messageId},
      );
    });
  }
}
