import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/app_button.dart';
import '../../../common/app_text_field.dart';
import '../../../common/responsive_text.dart';
import '../../../core/base/baseController.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';
import '../controller/auth_controller.dart';
import '../widgets/social_login_button.dart';

class SignUpView extends BasePage<AuthController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.symmetric(h: 24),
          child: Form(
            key: controller.signUpFormKey,
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
                SizedBox(height: 10.h),

                // Logo
                _buildLogo(),

                SizedBox(height: 32.h),

                // Title text
                ResponsiveText.title(
                  'Create an Account',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),

                SizedBox(height: 8.h),

                ResponsiveText.bodyMedium(
                  'A handful of learning content',
                  color: AppColors.textSecondary,
                ),

                SizedBox(height: 40.h),

                // Username field
                AppTextField(
                  controller: controller.usernameController,
                  hint: 'Username',
                  label: 'Username',
                  prefixIcon: Icons.person_outline,
                  validator: controller.validateUsername,
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(height: 16.h),

                // Email field
                AppTextField.email(
                  controller: controller.identifierController,
                  hint: 'Email id',
                  validator: controller.validateIdentifier,
                ),

                SizedBox(height: 16.h),
                // phone field
                AppTextField.phone(
                  controller: controller.phoneController,
                  hint: 'Phone number',
                  validator: controller.validatePhone,
                ),
                SizedBox(height: 16.h),
                // Password field
                AppTextField.password(
                  controller: controller.passwordController,
                  hint: 'Password',
                  validator: controller.validatePassword,
                  textInputAction: TextInputAction.done,
                ),

                SizedBox(height: 20.h),

                // Terms and conditions checkbox
                Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: Checkbox(
                          value: controller.agreeToTerms.value,
                          onChanged: controller.toggleAgreeToTerms,
                          activeColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'I hereby agree to the '),
                              TextSpan(
                                text: 'Terms & Condition',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.openTermsConditions,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'privacy policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.openPrivacyPolicy,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Create account button
                Obx(
                  () => AppButton.primary(
                    text: 'Create Account',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signUp,
                    isLoading: controller.isLoading.value,
                  ),
                ),

                SizedBox(height: 32.h),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveText.bodySmall(
                      'Already have an account? ',
                      color: AppColors.textSecondary,
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: ResponsiveText.bodySmall(
                        'Sign in',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

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
