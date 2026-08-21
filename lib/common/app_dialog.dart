import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';
import 'responsive_text.dart';
import 'app_button.dart';

/// Reusable Dialog Widget for OTT App
///
/// Usage:
/// ```dart
/// AppDialog.show(
///   context: context,
///   title: "Confirm",
///   message: "Are you sure?",
///   primaryButtonText: "Yes",
///   onPrimaryPressed: () {},
/// )
///
/// AppDialog.alert(context: context, title: "Error", message: "Something went wrong")
/// AppDialog.confirm(context: context, title: "Delete", message: "Delete item?", onConfirm: () {})
/// ```
class AppDialog {
  AppDialog._();

  /// Show a custom dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.scrim.withValues(alpha: 0.5),
      builder: (context) => _DialogContent(
        title: title,
        message: message,
        content: content,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  /// Show an alert dialog (OK only)
  static Future<void> alert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      onPrimaryPressed: () => Navigator.of(context).pop(),
      icon: icon ?? Icons.info_outline,
      iconColor: AppColors.primary,
    );
  }

  /// Show a confirmation dialog (Yes/No)
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: () {
        Navigator.of(context).pop(true);
        onConfirm?.call();
      },
      onSecondaryPressed: () {
        Navigator.of(context).pop(false);
        onCancel?.call();
      },
      icon: icon ?? Icons.help_outline,
      iconColor: AppColors.warning,
    );
  }

  /// Show a delete confirmation dialog
  static Future<bool?> delete({
    required BuildContext context,
    String title = 'Delete',
    String message = 'Are you sure you want to delete this item?',
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    VoidCallback? onDelete,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: () {
        Navigator.of(context).pop(true);
        onDelete?.call();
      },
      onSecondaryPressed: () => Navigator.of(context).pop(false),
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
    );
  }

  /// Show a success dialog
  static Future<void> success({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      onPrimaryPressed: () => Navigator.of(context).pop(),
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
    );
  }

  /// Show an error dialog
  static Future<void> error({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      onPrimaryPressed: () => Navigator.of(context).pop(),
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    );
  }
}

class _DialogContent extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;
  final Color? iconColor;

  const _DialogContent({
    required this.title,
    this.message,
    this.content,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.all(20)),
      child: Padding(
        padding: AppPaddings.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28.w,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              Spacing.h(16),
            ],

            // Title
            ResponsiveText.title(title, textAlign: TextAlign.center),
            Spacing.h(8),

            // Message
            if (message != null) ...[
              ResponsiveText.bodyMedium(
                message!,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              Spacing.h(16),
            ],

            // Custom content
            if (content != null) ...[content!, Spacing.h(16)],

            // Buttons
            if (primaryButtonText != null || secondaryButtonText != null)
              Row(
                children: [
                  if (secondaryButtonText != null)
                    Expanded(
                      child: AppButton.outlined(
                        text: secondaryButtonText!,
                        onPressed: onSecondaryPressed,
                      ),
                    ),
                  if (primaryButtonText != null && secondaryButtonText != null)
                    Spacing.w(12),
                  if (primaryButtonText != null)
                    Expanded(
                      child: AppButton.primary(
                        text: primaryButtonText!,
                        onPressed: onPrimaryPressed,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

