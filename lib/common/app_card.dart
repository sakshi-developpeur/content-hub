import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';

/// Reusable Card Widget for OTT App
///
/// Usage:
/// ```dart
/// AppCard(
///   child: Text("Content"),
///   onTap: () {},
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin ?? AppMargin.all(0),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: AppRadius.all(borderRadius ?? 16),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.all(borderRadius ?? 16),
        child: Padding(padding: padding ?? AppPaddings.all(16), child: child),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Gradient Card variant
class AppGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;
  final double? width;
  final double? height;

  const AppGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.gradientColors,
    this.gradientBegin,
    this.gradientEnd,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin ?? AppMargin.all(0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [AppColors.primary, AppColors.secondary],
          begin: gradientBegin ?? Alignment.topLeft,
          end: gradientEnd ?? Alignment.bottomRight,
        ),
        borderRadius: AppRadius.all(borderRadius ?? 16),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.all(borderRadius ?? 16),
        child: Padding(padding: padding ?? AppPaddings.all(16), child: child),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

