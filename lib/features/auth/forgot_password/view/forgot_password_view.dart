import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/app_button.dart';
import 'package:estoriz/common/app_text_field.dart';
import 'package:estoriz/common/responsive_text.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/core/value/dimension.dart';
import 'package:estoriz/features/auth/forgot_password/controller/forgot_password_controller.dart';

class ForgotPasswordView extends BasePage<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.symmetric(h: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Icon
              _buildIcon(),

              SizedBox(height: 24.h),

              // Title
              ResponsiveText.bodyMedium(
                'Forgot Password',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),

              SizedBox(height: 16.h),

              // Subtitle
              ResponsiveText.bodyMedium(
                'A handful of model sentence structures',
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),

              SizedBox(height: 48.h),

              // Phone field
              AppTextField.phone(
                controller: controller.phoneController,
                hint: 'Phone',
                validator: controller.validatePhone,
              ),

              SizedBox(height: 32.h),

              // Continue button
              Obx(
                () => AppButton.primary(
                  text: 'Continue',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.sendForgotPasswordOtp,
                  isLoading: controller.isLoading.value,
                ),
              ),

              SizedBox(height: 24.h),

              // Info text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a '),
                    TextSpan(
                      text: 'Verification Code',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' to your\nPhone Number'),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.all(20),
      ),
      child: Icon(
        Icons.password_rounded,
        size: 40.w,
        color: AppColors.onPrimary,
      ),
    );
  }
}

