import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/app_button.dart';
import 'package:estoriz/common/responsive_text.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/constants/app_constant.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/core/value/dimension.dart';
import 'package:estoriz/features/auth/forgot_password/controller/forgot_password_controller.dart';

class PasswordChangedSuccessView extends BasePage<ForgotPasswordController> {
  const PasswordChangedSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.symmetric(h: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Success emoji image
              Image.asset(
                AppConstant.successfullyChangesPasswordEmoji,
                height: 120.h,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.check_circle_outline,
                    size: 120.w,
                    color: AppColors.success,
                  );
                },
              ),

              SizedBox(height: 48.h),

              // Title
              ResponsiveText.title(
                'Password Changed\nSuccessfully!',
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),

              SizedBox(height: 16.h),

              // Subtitle
              Padding(
                padding: AppPaddings.symmetric(h: 24),
                child: ResponsiveText.bodyMedium(
                  'Your password has been updated successfully. You can now sign in with your new password to access your account.',
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 3),

              // Sign in button
              AppButton.primary(
                text: 'Sign in',
                onPressed: () => Get.offAllNamed(AppRoutes.login),
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}

