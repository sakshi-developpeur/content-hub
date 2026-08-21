import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/app_button.dart';
import '../../../common/responsive_text.dart';
import '../../../core/base/baseController.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';
import '../controller/auth_controller.dart';
import '../widgets/otp_input_widget.dart';

class OtpVerificationView extends BasePage<AuthController> {
  const OtpVerificationView({super.key});

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
              SizedBox(height: 60.h),

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
                  'We sent a verification code to\nyour ${controller.loginOtpTargetLabel} ${controller.maskedLoginIdentifier}',
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 48.h),

              // OTP Input boxes
              OtpInputWidget(
                length: 6,
                onCompleted: controller.onOtpCompleted,
                onChanged: controller.onOtpChanged,
              ),

              SizedBox(height: 48.h),

              // Verify button
              Obx(
                () => AppButton.primary(
                  text: 'Verify Code',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyOtp,
                  isLoading: controller.isLoading.value,
                ),
              ),

              SizedBox(height: 24.h),

              // Resend code link
              Obx(
                () => GestureDetector(
                  onTap: controller.canResendOtp.value
                      ? controller.resendOtp
                      : null,
                  child: controller.canResendOtp.value
                      ? ResponsiveText.bodyMedium(
                          'Resend Code',
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        )
                      : ResponsiveText.bodyMedium(
                          'Resend code in ${controller.resendCountdown.value}s',
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
