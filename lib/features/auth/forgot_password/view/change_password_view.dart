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

class ChangePasswordView extends BasePage<ForgotPasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.symmetric(h: 24),
          child: Form(
            key: controller.changePasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),

                // Icon
                _buildIcon(),

                SizedBox(height: 40.h),

                // Title
                ResponsiveText.title(
                  'Change Password',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),

                SizedBox(height: 12.h),

                // Subtitle
                ResponsiveText.bodyMedium(
                  'Your password length consists of\n6-characters',
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                ),

                SizedBox(height: 48.h),

                // New Password field
                AppTextField.password(
                  controller: controller.newPasswordController,
                  hint: 'New Password',
                  validator: controller.validatePassword,
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(height: 16.h),

                // Confirm Password field
                AppTextField.password(
                  controller: controller.confirmPasswordController,
                  hint: 'Confirm Password',
                  validator: controller.validateConfirmPassword,
                  textInputAction: TextInputAction.done,
                ),

                SizedBox(height: 48.h),

                // Save Password button
                Obx(
                  () => AppButton.primary(
                    text: 'Save Password',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveNewPassword,
                    isLoading: controller.isLoading.value,
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
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

