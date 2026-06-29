import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../screens/payslips_screen.dart';
import '../screens/announcements_screen.dart';
import '../screens/leave_requests_screen.dart';
import '../main.dart'; // to get navigatorKey

class NotificationService {
  static bool _isInitialized = false;

  /// Initialize Firebase and FCM configurations
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint("Firebase successfully initialized for notifications.");

      final messaging = FirebaseMessaging.instance;

      // 1. Request permission
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Configure foreground notification presentation
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Register token updates
      await syncFcmToken();

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint("FCM Token refreshed: $newToken");
        final loggedIn = await ApiService.isLoggedIn();
        if (loggedIn) {
          await ApiService.updateFcmToken(newToken);
        }
      });

      // 4. Handle incoming messages in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Received a foreground push notification: ${message.notification?.title}");
      });

      // 5. Handle notification taps (Deep Linking)
      // When the app is in the background and opened via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("Notification tapped (onMessageOpenedApp): ${message.notification?.title}");
        handleNotificationTap(message);
      });

      // When the app is terminated and launched via notification tap
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint("App launched via notification (getInitialMessage): ${message.notification?.title}");
          Future.delayed(const Duration(milliseconds: 500), () {
            handleNotificationTap(message);
          });
        }
      });
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }
  }

  /// Route user based on push notification data payload
  static void handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final String? type = data['type'];
    if (type == null) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'payslip':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PayslipsScreen()),
        );
        break;
      case 'announcement':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
        );
        break;
      case 'leave':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LeaveRequestsScreen()),
        );
        break;
    }
  }

  /// Fetch and upload FCM token to Laravel server if user is logged in
  static Future<void> syncFcmToken() async {
    try {
      final loggedIn = await ApiService.isLoggedIn();
      if (!loggedIn) {
        debugPrint("User not logged in; skipping FCM token sync.");
        return;
      }

      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint("FCM Token synchronized: $token");
        await ApiService.updateFcmToken(token);
      }
    } catch (e) {
      debugPrint("Error syncing FCM token: $e");
    }
  }
}
