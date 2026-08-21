import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';

/// Cached Network Image Widget for OTT App
///
/// Usage:
/// ```dart
/// AppCachedImage(imageUrl: "https://example.com/image.jpg", width: 100, height: 100)
/// AppCachedImage.circular(imageUrl: "...", size: 80)  // For avatars
/// AppCachedImage.rounded(imageUrl: "...", width: 200, height: 150, borderRadius: 16)
/// ```
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final _ImageShape _shape;
  final double? borderRadius;
  final double? size;

  const AppCachedImage._({
    required this.imageUrl,
    required _ImageShape shape,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.size,
  }) : _shape = shape;

  /// Standard rectangular image
  factory AppCachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
  }) {
    return AppCachedImage._(
      imageUrl: imageUrl,
      shape: _ImageShape.rectangle,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
    );
  }

  /// Circular image (for avatars)
  factory AppCachedImage.circular({
    required String imageUrl,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
  }) {
    return AppCachedImage._(
      imageUrl: imageUrl,
      shape: _ImageShape.circular,
      size: size,
      width: size,
      height: size,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
    );
  }

  /// Rounded corners image
  factory AppCachedImage.rounded({
    required String imageUrl,
    double? width,
    double? height,
    double borderRadius = 12,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
  }) {
    return AppCachedImage._(
      imageUrl: imageUrl,
      shape: _ImageShape.rounded,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _getBorderRadius(),
      child: Container(
        width: width?.w,
        height: height?.h,
        color: backgroundColor ?? AppColors.surface,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width?.w,
          height: height?.h,
          fit: fit,
          placeholder: (context, url) =>
              placeholder ?? _buildLoadingPlaceholder(),
          errorWidget: (context, url, error) =>
              errorWidget ?? _buildErrorPlaceholder(),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (_shape) {
      case _ImageShape.rectangle:
        return BorderRadius.zero;
      case _ImageShape.circular:
        return BorderRadius.circular(1000);
      case _ImageShape.rounded:
        return AppRadius.all(borderRadius ?? 12);
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width?.w ?? size?.w,
      height: height?.h ?? size?.h,
      color: AppColors.shimmerBase,
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width?.w ?? size?.w,
      height: height?.h ?? size?.h,
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 32.w,
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}

/// Avatar variant with initials fallback
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
  });

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return AppCachedImage.circular(
        imageUrl: imageUrl!,
        size: size,
        errorWidget: _buildInitialsAvatar(),
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: (size * 0.4).sp,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

enum _ImageShape { rectangle, circular, rounded }

