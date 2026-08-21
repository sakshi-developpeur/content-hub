import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/app_button.dart';
import 'package:estoriz/common/responsive_text.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/core/value/dimension.dart';
import 'package:estoriz/features/auth/widgets/otp_input_widget.dart';
import 'package:estoriz/features/auth/forgot_password/controller/forgot_password_controller.dart';

class ForgotPasswordOtpView extends BasePage<ForgotPasswordController> {
  const ForgotPasswordOtpView({super.key});

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

              SizedBox(height: 40.h),

              // Title
              ResponsiveText.title(
                'Enter a Code',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),

              SizedBox(height: 16.h),

              // Subtitle with phone number
              Obx(
                () => ResponsiveText.bodyMedium(
                  'We sent a verification code to\nyour phone number ${controller.maskedPhoneNumber}',
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 48.h),

              // OTP Input boxes
              OtpInputWidget(
                length: 6,
                onCompleted: controller.onForgotPasswordOtpCompleted,
                onChanged: controller.onForgotPasswordOtpChanged,
              ),

              SizedBox(height: 48.h),

              // Change Password button
              Obx(
                () => AppButton.primary(
                  text: 'Change Password',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyForgotPasswordOtp,
                  isLoading: controller.isLoading.value,
                ),
              ),

              SizedBox(height: 24.h),

              // Resend code link
              Obx(
                () => GestureDetector(
                  onTap: controller.canResendForgotPasswordOtp.value
                      ? controller.resendForgotPasswordOtp
                      : null,
                  child: controller.canResendForgotPasswordOtp.value
                      ? ResponsiveText.bodyMedium(
                          'Resend Code',
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        )
                      : ResponsiveText.bodyMedium(
                          'Resend code in ${controller.forgotPasswordResendCountdown.value}s',
                          color: AppColors.textDisabled,
                        ),
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
