import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';

/// Reusable Icon Button Widget for OTT App
///
/// Usage:
/// ```dart
/// AppIconButton(icon: Icons.favorite, onPressed: () {})
/// AppIconButton.filled(icon: Icons.add, onPressed: () {})
/// AppIconButton.outlined(icon: Icons.share, onPressed: () {})
/// ```
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final double? iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? tooltip;
  final _IconButtonType _type;

  const AppIconButton._({
    required this.icon,
    required this.onPressed,
    required _IconButtonType type,
    this.size,
    this.iconSize,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.tooltip,
  }) : _type = type;

  /// Standard icon button
  factory AppIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double? size,
    double? iconSize,
    Color? iconColor,
    String? tooltip,
  }) {
    return AppIconButton._(
      icon: icon,
      onPressed: onPressed,
      type: _IconButtonType.standard,
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      tooltip: tooltip,
    );
  }

  /// Filled icon button with background
  factory AppIconButton.filled({
    required IconData icon,
    required VoidCallback? onPressed,
    double? size,
    double? iconSize,
    Color? iconColor,
    Color? backgroundColor,
    String? tooltip,
  }) {
    return AppIconButton._(
      icon: icon,
      onPressed: onPressed,
      type: _IconButtonType.filled,
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
    );
  }

  /// Outlined icon button
  factory AppIconButton.outlined({
    required IconData icon,
    required VoidCallback? onPressed,
    double? size,
    double? iconSize,
    Color? iconColor,
    Color? borderColor,
    String? tooltip,
  }) {
    return AppIconButton._(
      icon: icon,
      onPressed: onPressed,
      type: _IconButtonType.outlined,
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      borderColor: borderColor,
      tooltip: tooltip,
    );
  }

  /// Small icon button
  factory AppIconButton.small({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? iconColor,
    String? tooltip,
  }) {
    return AppIconButton._(
      icon: icon,
      onPressed: onPressed,
      type: _IconButtonType.standard,
      size: 32,
      iconSize: 18,
      iconColor: iconColor,
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = size ?? 40;
    final double iconSizeValue = iconSize ?? 24;

    Widget button;

    switch (_type) {
      case _IconButtonType.standard:
        button = _buildStandard(buttonSize, iconSizeValue);
        break;
      case _IconButtonType.filled:
        button = _buildFilled(buttonSize, iconSizeValue);
        break;
      case _IconButtonType.outlined:
        button = _buildOutlined(buttonSize, iconSizeValue);
        break;
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildStandard(double buttonSize, double iconSizeValue) {
    return SizedBox(
      width: buttonSize.w,
      height: buttonSize.h,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSizeValue.w,
          color: iconColor ?? AppColors.textPrimary,
        ),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(8)),
        ),
      ),
    );
  }

  Widget _buildFilled(double buttonSize, double iconSizeValue) {
    return SizedBox(
      width: buttonSize.w,
      height: buttonSize.h,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSizeValue.w,
          color: iconColor ?? AppColors.onPrimary,
        ),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(8)),
        ),
      ),
    );
  }

  Widget _buildOutlined(double buttonSize, double iconSizeValue) {
    return SizedBox(
      width: buttonSize.w,
      height: buttonSize.h,
      child: IconButton.outlined(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSizeValue.w,
          color: iconColor ?? AppColors.primary,
        ),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          side: BorderSide(color: borderColor ?? AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(8)),
        ),
      ),
    );
  }
}

enum _IconButtonType { standard, filled, outlined }

