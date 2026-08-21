import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';
import 'responsive_text.dart';

/// Reusable Button Widgets for OTT App
///
/// Usage:
/// ```dart
/// AppButton.primary(text: "Continue", onPressed: () {})
/// AppButton.secondary(text: "Cancel", onPressed: () {})
/// AppButton.outlined(text: "Learn More", onPressed: () {})
/// AppButton.text(text: "Skip", onPressed: () {})
/// AppButton.icon(text: "Add", icon: Icons.add, onPressed: () {})
/// ```
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final _ButtonType _type;
  final Color? textColor;
  final Color? backgroundColor;

  const AppButton._({
    required this.text,
    required this.onPressed,
    required _ButtonType type,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.textColor,
    this.backgroundColor,
  }) : _type = type;

  /// Primary filled button - for main CTAs
  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
    Color? backgroundColor,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      type: _ButtonType.primary,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
      backgroundColor: backgroundColor,
    );
  }

  /// Secondary button - less prominent actions
  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      type: _ButtonType.secondary,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  /// Outlined button - bordered style
  factory AppButton.outlined({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      type: _ButtonType.outlined,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  /// Text button - minimal style
  factory AppButton.text({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    Color? textColor,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      type: _ButtonType.text,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      textColor: textColor,
    );
  }

  /// Icon button with text
  factory AppButton.icon({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      type: _ButtonType.icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && onPressed != null;
    final bool showLoading = isLoading;
    final bool canPress = enabled && !showLoading;

    switch (_type) {
      case _ButtonType.primary:
        return _buildPrimaryButton(canPress, showLoading);
      case _ButtonType.secondary:
        return _buildSecondaryButton(canPress, showLoading);
      case _ButtonType.outlined:
        return _buildOutlinedButton(canPress, showLoading);
      case _ButtonType.text:
        return _buildTextButton(canPress, showLoading);
      case _ButtonType.icon:
        return _buildIconButton(canPress, showLoading);
    }
  }

  Widget _buildPrimaryButton(bool enabled, bool showLoading) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: backgroundColor != null 
              ? backgroundColor!.withValues(alpha: 0.5) 
              : AppColors.primary.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.38),
          padding: AppPaddings.symmetric(h: 24, v: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(12)),
        ),
        child: _buildButtonContent(AppColors.onPrimary, showLoading),
      ),
    );
  }

  Widget _buildSecondaryButton(bool enabled, bool showLoading) {
    return SizedBox(
      width: width,
      height: 48.h,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.onSecondary.withValues(
            alpha: 0.38,
          ),
          padding: AppPaddings.symmetric(h: 24, v: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(12)),
        ),
        child: _buildButtonContent(AppColors.onSecondary, showLoading),
      ),
    );
  }

  Widget _buildOutlinedButton(bool enabled, bool showLoading) {
    return SizedBox(
      width: width,
      height: 48.h,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: enabled
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.38),
            width: 1.5,
          ),
          padding: AppPaddings.symmetric(h: 24, v: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(12)),
        ),
        child: _buildButtonContent(AppColors.primary, showLoading),
      ),
    );
  }

  Widget _buildTextButton(bool enabled, bool showLoading) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding: AppPaddings.symmetric(h: 16, v: 10),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.all(8)),
      ),
      child: _buildButtonContent(textColor ?? AppColors.primary, showLoading),
    );
  }

  Widget _buildIconButton(bool enabled, bool showLoading) {
    return SizedBox(
      width: width,
      height: 48.h,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: showLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Icon(icon, size: 20.w),
        label: ResponsiveText.bodyMedium(
          text,
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.38),
          padding: AppPaddings.symmetric(h: 20, v: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(12)),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color color, bool showLoading) {
    if (showLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }

    if (icon != null && _type != _ButtonType.icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.w, color: color),
          Spacing.w(8),
          ResponsiveText.bodyMedium(
            text,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ],
      );
    }

    return ResponsiveText.bodyMedium(
      text,
      color: color,
      fontWeight: FontWeight.w600,
    );
  }
}

enum _ButtonType { primary, secondary, outlined, text, icon }
