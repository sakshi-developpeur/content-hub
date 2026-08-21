import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../app_launch_manager.dart';
import '../constants/app_constant.dart';
import '../utils/user_data.dart';
import 'notification_helper.dart';

/// Core notification service using OneSignal.
///
/// Handles SDK initialization, permission management, lifecycle-aware
/// notification handling (foreground, background, terminated), and
/// user identity linking for targeted push from the backend.
///
/// Register as a permanent [GetxService] so it persists across the
/// entire app lifecycle.
class NotificationService extends GetxService {
  // ── Singleton accessor ──────────────────────────────────────────
  static NotificationService get instance => Get.find<NotificationService>();

  // ── Observable state ────────────────────────────────────────────
  final RxBool isPermissionGranted = false.obs;
  final RxString playerId = ''.obs;
  final RxBool isInitialized = false.obs;

  // ── Initialisation ──────────────────────────────────────────────

  /// Call once from [main.dart] after dependency injection.
  Future<NotificationService> init() async {
    try {
      // Enable verbose logging in debug mode only
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      // Initialise SDK
      OneSignal.initialize(AppConstant.appId);

      // Setup all notification handlers
      requestPermission();
      _setupNotificationHandlers();
      _setupPermissionObserver();
      _setupSubscriptionObserver();

      // Fetch initial subscription / permission state
      _syncInitialState();

      isInitialized.value = true;
      debugPrint('[NotificationService] Initialised successfully');
    } catch (e, stackTrace) {
      debugPrint('[NotificationService] Init error: $e');
      debugPrint('[NotificationService] Stack: $stackTrace');
    }
    return this;
  }

  // ── Permission ──────────────────────────────────────────────────

  /// Request push notification permission.
  ///
  /// On Android 13+ this triggers the runtime dialog; on older Android
  /// versions permission is granted at install. On iOS it always shows
  /// the native prompt.
  Future<bool> requestPermission() async {
    try {
      final granted = await OneSignal.Notifications.requestPermission(true);
      isPermissionGranted.value = granted;
      debugPrint('[NotificationService] Permission granted: $granted');
      return granted;
    } catch (e) {
      debugPrint('[NotificationService] Permission request error: $e');
      return false;
    }
  }

  // ── User identity ───────────────────────────────────────────────

  /// Link the logged-in user's backend ID so the server can target
  /// notifications to this specific device/user pair.
  Future<void> setExternalUserId(String userId) async {
    if (userId.isEmpty) return;
    try {
      OneSignal.login(userId);
      debugPrint('[NotificationService] External user ID set: $userId');
    } catch (e) {
      debugPrint('[NotificationService] setExternalUserId error: $e');
    }
  }

  /// Unlink the user on logout so the device stops receiving
  /// user-targeted notifications.
  Future<void> removeExternalUserId() async {
    try {
      OneSignal.logout();
      debugPrint('[NotificationService] External user ID removed');
    } catch (e) {
      debugPrint('[NotificationService] removeExternalUserId error: $e');
    }
  }

  /// Link user after login using data from [UserData].
  void linkCurrentUser() {
    final userId = UserData().getLoginData.user?.id;
    if (userId != null && userId.isNotEmpty) {
      setExternalUserId(userId);
    }
  }

  // ── Subscription helpers ────────────────────────────────────────

  /// Get the OneSignal subscription (player) ID.
  /// The backend can use this to target individual devices.
  String? getSubscriptionId() {
    return OneSignal.User.pushSubscription.id;
  }

  /// Get the device push token (FCM on Android, APNs on iOS).
  String? getPushToken() {
    return OneSignal.User.pushSubscription.token;
  }

  // ── Private: Handlers ───────────────────────────────────────────

  /// Register notification event handlers for all lifecycle states.
  void _setupNotificationHandlers() {
    // ── Foreground ──
    // Fires when a notification arrives while the app is in the
    // foreground.  We intercept it to show a custom in-app banner
    // and prevent the default system notification.
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('[NotificationService] Foreground notification received');

      final notification = event.notification;
      final title = notification.title ?? '';
      final body = notification.body ?? '';
      final data = notification.additionalData ?? {};

      debugPrint('=====================================================');
      debugPrint('Title: ${notification.title}');
      debugPrint('Body: ${notification.body}');
      debugPrint('Notification ID: ${notification.notificationId}');
      debugPrint('Launch URL: ${notification.launchUrl}');

      debugPrint('Additional Data FULL: $data');

      // 🔥 Print specific key (example: type or screen)
      debugPrint('TYPE: ${data['type']}');
      debugPrint('SCREEN: ${data['screen']}');

      debugPrint('=====================================================');

      // Show a styled in-app banner (top snackbar)
      Future.delayed(const Duration(milliseconds: 100), () {
        NotificationHelper.showInAppNotification(
          title: title,
          body: body,
          data: data,
        );
      });

      // ALSO display the system notification in the status bar
      // so the user sees it even if the in-app banner is missed.
      event.notification.display();
    });

    // ── Background / Terminated (notification tapped) ──
    // Fires when user taps a notification that arrived while the app
    // was in background or terminated state.
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('[NotificationService] Notification clicked');
      AppLaunchManager.openedFromNotification = true;

      final data = event.notification.additionalData ?? {};
      if (kDebugMode) {
        print('Notification clicked data: $data');
      }
      NotificationHelper.handleNotificationNavigation(data);
    });
  }

  /// Observe permission state changes at runtime.
  void _setupPermissionObserver() {
    OneSignal.Notifications.addPermissionObserver((granted) {
      isPermissionGranted.value = granted;
      debugPrint('[NotificationService] Permission changed: $granted');
    });
  }

  /// Observe push subscription changes (player ID / push token).
  void _setupSubscriptionObserver() {
    OneSignal.User.pushSubscription.addObserver((state) {
      final id = state.current.id;
      final token = state.current.token;
      playerId.value = id ?? '';

      debugPrint('[NotificationService] Subscription changed');
      debugPrint('[NotificationService] Player ID: $id');
      debugPrint('[NotificationService] Push Token: $token');
    });
  }

  /// Read the current permission & subscription state at startup.
  void _syncInitialState() {
    isPermissionGranted.value = OneSignal.Notifications.permission;
    playerId.value = OneSignal.User.pushSubscription.id ?? '';

    debugPrint(
      '[NotificationService] Initial permission: ${isPermissionGranted.value}',
    );
    debugPrint('[NotificationService] Initial player ID: ${playerId.value}');
  }

  // ── Lifecycle ───────────────────────────────────────────────────

  @override
  void onClose() {
    // OneSignal handles its own cleanup; nothing special needed.
    super.onClose();
  }
}
