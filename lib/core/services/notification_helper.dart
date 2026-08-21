import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_launch_manager.dart';
import '../routes/app_routes.dart';

/// Static utility class for notification-related helpers.
///
/// Keeps navigation / UI logic separate from the OneSignal service so
/// [NotificationService] stays focused on SDK communication.
class NotificationHelper {
  NotificationHelper._(); // prevent instantiation

  // ── Deep-link navigation ────────────────────────────────────────

  /// Parse the notification payload and navigate to the correct screen.
  ///
  /// The [data] map comes from `notification.additionalData` and
  /// should contain a `type` key (and optionally an `id`) set by your
  /// backend when creating the notification in OneSignal.
  ///
  /// Example payloads from backend:
  /// ```json
  /// { "type": "chat",         "id": "astrologer_123" }
  /// { "type": "booking",      "id": "booking_456"    }
  /// { "type": "horoscope"                             }
  /// { "type": "offer",        "id": "offer_789"      }
  /// ```
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint('[NotificationHelper] Handling navigation with data: $data');

    final String type = (data['type'] ?? '').toString().toLowerCase();
    final String? id = data['id']?.toString();

    if (kDebugMode) {
      print('Notification type: $type');
      print('Notification id: $id');
      print('Notification data: $data');
    }
    // Defer navigation until the app is fully ready (covers the
    // terminated → cold-start scenario where GetMaterialApp may not
    // yet have a navigator context).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateByType(type, id, data);
      Future.delayed(const Duration(seconds: 1), () {
        AppLaunchManager.openedFromNotification = false;
      });
    });
  }

  /// Route to the appropriate screen based on notification [type].
  ///
  /// Extend this switch-case as you add more notification types on
  /// the backend.
  static void _navigateByType(
    String type,
    String? id,
    Map<String, dynamic> data,
  ) {
    try {
      switch (type) {
        // ── Chat notification ──
        case 'chat':
          if (id != null) {
            // Get.toNamed(AppRoutes.chatQueue);
          }
          break;

        // ── Call notification ──
        case 'call':
          if (id != null) {
            // Get.toNamed(AppRoutes.voiceCallQueue);
          }
          break;

        // ── Booking / appointment ──
        // case 'booking':
        //   Get.toNamed(AppRoutes.bo, arguments: {'bookingId': id, ...data});
        //   break;

        // ── Daily horoscope ──
        // case 'horoscope':
        //   Get.toNamed(AppRoutes.horoscope);
        //   break;

        // ── Promotional / offer ──
        case 'offer':
        case 'promotion':
          // Navigate to the dashboard; specific offer detail can be
          // added later when an offer-detail screen exists.
          // Get.toNamed(AppRoutes.userDashboard);
          break;

        // ── Default: open dashboard ──
        default:
          debugPrint(
            '[NotificationHelper] Unknown notification type: "$type", '
            'navigating to dashboard',
          );
          // Get.toNamed(AppRoutes.userDashboard);
          break;
      }
    } catch (e) {
      debugPrint('[NotificationHelper] Navigation error: $e');
      // Fallback: try to open dashboard
      try {
        // Get.toNamed(AppRoutes.userDashboard);
      } catch (_) {
        // Navigation system not ready; silently ignore
      }
    }
  }

  // ── In-app notification banner ──────────────────────────────────

  /// Display a styled in-app notification banner (GetX SnackBar)
  /// when a push arrives while the app is in the foreground.
  /// Display a styled in-app notification banner
  static void showInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    // Avoid showing empty notifications
    if (title.isEmpty && body.isEmpty) return;

    // 1. Use Get.overlayContext instead of Get.context!
    // final context = Get.overlayContext;
    final navigatorState = Get.key.currentState;

    // 2. Safety check: ensure the context is ready
    if (navigatorState == null) {
      debugPrint(
        '[NotificationHelper] Failed to show snackbar: overlayContext is null.',
      );
      return;
    }

    // 3. Show the custom snackbar
    CustomSnackBar.show(
      navigatorState: navigatorState,
      title: title,
      body: body,
      duration: const Duration(seconds: 3),
      data: data,
    );
  }
}

class CustomSnackBar {
  static void show({
    required NavigatorState navigatorState,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Get overlay from NavigatorState directly — this is always valid
    final overlayState = navigatorState.overlay;

    if (overlayState == null) {
      debugPrint('[CustomSnackBar] Overlay is null, cannot show snackbar.');
      return;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CustomSnackBarWidget(
        title: title.isNotEmpty ? title : 'Notification',
        body: body,
        data: data,
        displayDuration: duration,
        onDismissed: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _CustomSnackBarWidget extends StatefulWidget {
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final Duration displayDuration;
  final VoidCallback onDismissed;

  const _CustomSnackBarWidget({
    required this.title,
    required this.body,
    this.data,
    required this.displayDuration,
    required this.onDismissed,
  });

  @override
  State<_CustomSnackBarWidget> createState() => _CustomSnackBarWidgetState();
}

class _CustomSnackBarWidgetState extends State<_CustomSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1.5), // Start above the screen
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Start slide-in animation
    _controller.forward();

    // Auto-dismiss timer (2-3 seconds as requested)
    _dismissTimer = Timer(widget.displayDuration, _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      _dismissTimer?.cancel();
      _controller.reverse().then((_) {
        widget.onDismissed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add safe area top padding so it doesn't overlap the status bar
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12, // 12 is the vertical margin you requested
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: GestureDetector(
            onTap: () {
              // Handle your navigation logic here
              if (widget.data != null && widget.data!.isNotEmpty) {
                // handleNotificationNavigation(widget.data);
                debugPrint('Banner tapped with data: ${widget.data}');
              }
              _dismiss(); // Optional: dismiss immediately on tap
            },
            // Swipe up to dismiss manually
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -5) {
                _dismiss();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFFFF9933), // saffron accent
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.body,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
