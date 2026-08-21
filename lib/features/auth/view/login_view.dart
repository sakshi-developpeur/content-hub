import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/base/baseController.dart';
import '../../../common/app_button.dart';
import '../../../common/app_text_field.dart';
import '../../../common/responsive_text.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';
import '../controller/auth_controller.dart';
import '../widgets/social_login_button.dart';

class LoginView extends BasePage<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.symmetric(h: 24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),

                // Logo
                _buildLogo(),

                SizedBox(height: 32.h),

                // Welcome text
                ResponsiveText.title(
                  'Welcome',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),

                SizedBox(height: 8.h),

                ResponsiveText.bodyMedium(
                  'A handful of learning content',
                  color: AppColors.textSecondary,
                ),

                SizedBox(height: 40.h),

                // Email or phone field
                AppTextField.email(
                  controller: controller.loginIdentifierController,
                  hint: "Email or phone",
                  validator: controller.validateIdentifier,
                ),

                SizedBox(height: 16.h),

                // Password field
                AppTextField.password(
                  controller: controller.loginPasswordController,
                  hint: 'Password',
                  validator: controller.validatePassword,
                  textInputAction: TextInputAction.done,
                ),

                SizedBox(height: 12.h),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: controller.goToForgotPassword,
                    child: ResponsiveText.bodySmall(
                      'Forgot Password?',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Sign in button
                Obx(
                  () => AppButton.primary(
                    text: 'Sign in',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.login,
                    isLoading: controller.isLoading.value,
                  ),
                ),

                SizedBox(height: 24.h),

                // Or divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.outline,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: ResponsiveText.bodySmall(
                        'or',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.outline,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Google sign in
                Obx(
                  () => SocialLoginButton.google(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithGoogle,
                  ),
                ),

                // Apple sign in (iOS only)
                if (SocialLoginButton.showApple) ...[
                  SizedBox(height: 12.h),
                  Obx(
                    () => SocialLoginButton.apple(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.signInWithApple,
                    ),
                  ),
                ],
                SizedBox(height: 32.h),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveText.bodySmall(
                      "Don't have an account? ",
                      color: AppColors.textSecondary,
                    ),
                    GestureDetector(
                      onTap: controller.goToSignUp,
                      child: ResponsiveText.bodySmall(
                        'Sign up',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // Terms and Privacy links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.openPrivacyPolicy,
                      child: ResponsiveText.bodySmall(
                        'Privacy Policy',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ResponsiveText.bodySmall(
                      '  |  ',
                      color: AppColors.textHint,
                    ),
                    GestureDetector(
                      onTap: controller.openTermsConditions,
                      child: ResponsiveText.bodySmall(
                        'Terms & Condition',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      AppConstant.appLogo,
      height: 120.h,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 120.h,
          width: 120.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.all(16),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 60.w,
            color: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildFingerprintButton() {
    return GestureDetector(
      onTap: controller.authenticateWithFingerprint,
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.all(16),
        ),
        child: Icon(Icons.fingerprint, size: 28.w, color: AppColors.onPrimary),
      ),
    );
  }
}
