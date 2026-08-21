import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/app_colors.dart';

/// Reusable Loading/Progress Widgets for OTT App
///
/// Usage:
/// ```dart
/// AppLoading.circular()
/// AppLoading.circular(size: 48, color: AppColors.secondary)
/// AppLoading.shimmer(width: 100, height: 20)
/// AppLoading.fullScreen()
/// ```
class AppLoading extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;
  final _LoadingType _type;
  final double? width;
  final double? height;
  final double? borderRadius;

  const AppLoading._({
    this.size,
    this.color,
    this.strokeWidth = 3,
    required _LoadingType type,
    this.width,
    this.height,
    this.borderRadius,
  }) : _type = type;

  /// Circular progress indicator
  factory AppLoading.circular({
    double? size,
    Color? color,
    double strokeWidth = 3,
  }) {
    return AppLoading._(
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      type: _LoadingType.circular,
    );
  }

  /// Shimmer placeholder
  factory AppLoading.shimmer({
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return AppLoading._(
      width: width,
      height: height,
      borderRadius: borderRadius,
      type: _LoadingType.shimmer,
    );
  }

  /// Full screen loading overlay
  factory AppLoading.fullScreen({Color? color, double? size}) {
    return AppLoading._(
      color: color,
      size: size,
      type: _LoadingType.fullScreen,
    );
  }

  /// Linear progress indicator
  factory AppLoading.linear({Color? color}) {
    return AppLoading._(color: color, type: _LoadingType.linear);
  }

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _LoadingType.circular:
        return _buildCircular();
      case _LoadingType.shimmer:
        return _buildShimmer();
      case _LoadingType.fullScreen:
        return _buildFullScreen();
      case _LoadingType.linear:
        return _buildLinear();
    }
  }

  Widget _buildCircular() {
    return SizedBox(
      width: size ?? 32.w,
      height: size ?? 32.h,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primary,
      ),
    );
  }

  Widget _buildShimmer() {
    return _ShimmerWidget(
      width: width ?? double.infinity,
      height: height ?? 20.h,
      borderRadius: borderRadius ?? 8,
    );
  }

  Widget _buildFullScreen() {
    return Container(
      color: AppColors.scaffoldBackground.withValues(alpha: 0.8),
      child: Center(
        child: SizedBox(
          width: size ?? 48.w,
          height: size ?? 48.h,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            color: color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLinear() {
    return LinearProgressIndicator(
      color: color ?? AppColors.primary,
      backgroundColor: AppColors.outline,
    );
  }
}

/// Shimmer animation widget
class _ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerWidget({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _LoadingType { circular, shimmer, fullScreen, linear }

