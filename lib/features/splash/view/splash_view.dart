import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.find<SplashController>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.scaffoldBackground,
              AppColors.primary.withValues(alpha: 0.3),
              AppColors.scaffoldBackground,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ..._buildBackgroundCircles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow effect
                  _buildLogo(),

                  SizedBox(height: 40.h),

                  // App name
                  _buildAppName(),

                  SizedBox(height: 16.h),

                  // Tagline
                  _buildTagline(),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80.h,
              left: 0,
              right: 0,
              child: _buildLoadingIndicator(),
            ),

            // Version text
            Positioned(
              bottom: 24.h,
              left: 0,
              right: 0,
              child: _buildVersionText(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      // Top-right glowing circle
      Positioned(
        top: -100.h,
        right: -100.w,
        child: Container(
          width: 300.w,
          height: 300.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.4),
                AppColors.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),

      // Bottom-left glowing circle
      Positioned(
        bottom: -150.h,
        left: -100.w,
        child: Container(
          width: 350.w,
          height: 350.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.3),
                AppColors.secondary.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),

      // Center accent
      Positioned(
        top: 200.h,
        left: 50.w,
        child: Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.tertiary.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildLogo() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow_rounded,
          size: 60.w,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppColors.textPrimary,
          AppColors.primary,
          AppColors.textPrimary,
        ],
      ).createShader(bounds),
      child: Text(
        'Estoriz',
        style: TextStyle(
          fontSize: 42.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Stream. Watch. Enjoy.',
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 32.w,
          height: 32.h,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionText() {
    return Obx(
      () => Text(
        controller.appVersion.value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textDisabled,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
