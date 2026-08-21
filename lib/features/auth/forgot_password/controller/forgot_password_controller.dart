import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/features/auth/service/auth_service.dart';

class ForgotPasswordController extends BaseController {
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();

  // OTP states
  final RxString forgotPasswordOtp = ''.obs;
  final RxString userPhoneNumber = ''.obs;
  final RxString resetPasswordToken = ''.obs;
  final RxBool canResendOtp = false.obs;
  final RxInt resendCountdown = 30.obs;
  Timer? _resendTimer;

  /// Masked phone number for display
  String get maskedPhoneNumber => '(${userPhoneNumber.value})';

  @override
  void onClose() {
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    forgotPasswordOtp.close();
    userPhoneNumber.close();
    resetPasswordToken.close();
    canResendOtp.close();
    resendCountdown.close();
    canResendForgotPasswordOtp.close();
    forgotPasswordResendCountdown.close();
    _resendTimer?.cancel();
    _forgotPasswordResendTimer?.cancel();
    super.onClose();
  }

  // ============================================
  // FORGOT PASSWORD METHODS
  // ============================================

  /// Send forgot password OTP
  Future<void> sendForgotPasswordOtp() async {
    final inputMobile = phoneController.text.trim();
    if (inputMobile.isEmpty) {
      showWarningMessage(message: 'Please enter your mobile number');
      return;
    }

    final validationMessage = validatePhone(inputMobile);
    if (validationMessage != null) {
      showWarningMessage(message: validationMessage);
      return;
    }

    final mobile = _normalizeMobile(inputMobile);

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.sendForgotPasswordOtp(
            mobile: mobile,
          );

          if (result.isSuccess) {
            userPhoneNumber.value = mobile;
            forgotPasswordOtp.value = '';
            resetPasswordToken.value = '';
            _startForgotPasswordResendCountdown();
            Get.toNamed(AppRoutes.forgotPasswordOtp);
          } else {
            showErrorMessage(message: result.message ?? 'Failed to send OTP');
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Save new password
  Future<void> saveNewPassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    final token = resetPasswordToken.value.trim();
    if (token.isEmpty) {
      showErrorMessage(
        message: 'Verification token missing. Please verify OTP again.',
      );
      Get.offAllNamed(AppRoutes.forgotPassword);
      return;
    }

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.resetPassword(
            token: token,
            newPassword: newPasswordController.text.trim(),
            confirmPassword: confirmPasswordController.text.trim(),
          );

          if (result.isSuccess) {
            showSuccessMessage(message: 'Password changed successfully');
            Get.offAllNamed(AppRoutes.passwordChangedSuccess);
          } else {
            showErrorMessage(
              message: result.message ?? 'Failed to change password',
            );
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Navigate back to login
  void goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  // ============================================
  // VALIDATORS
  // ============================================

  /// Phone validator
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final normalized = _normalizeMobile(value);
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Confirm password validator
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ============================================
  // FORGOT PASSWORD METHODS
  // ============================================

  /// Called when forgot password OTP input changes
  void onForgotPasswordOtpChanged(String otp) {
    forgotPasswordOtp.value = otp;
  }

  /// Called when forgot password OTP input is completed
  void onForgotPasswordOtpCompleted(String otp) {
    forgotPasswordOtp.value = otp;
  }

  /// Verify forgot password OTP
  Future<void> verifyForgotPasswordOtp() async {
    if (forgotPasswordOtp.value.length != 6) {
      showWarningMessage(message: 'Please enter the complete 6-digit code');
      return;
    }

    final mobile = userPhoneNumber.value.trim();
    if (mobile.isEmpty) {
      showErrorMessage(message: 'Session expired. Please request OTP again.');
      Get.offAllNamed(AppRoutes.forgotPassword);
      return;
    }

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.verifyForgotPasswordOtp(
            mobile: mobile,
            otp: forgotPasswordOtp.value,
          );

          if (result.isSuccess && result.data != null) {
            resetPasswordToken.value = result.data!;
            Get.toNamed(AppRoutes.changePassword);
          } else {
            showErrorMessage(message: result.message ?? 'Verification failed');
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Resend forgot password OTP
  Future<void> resendForgotPasswordOtp() async {
    if (!canResendForgotPasswordOtp.value) return;

    final mobile = userPhoneNumber.value.trim();
    if (mobile.isEmpty) {
      showErrorMessage(message: 'Session expired. Please request OTP again.');
      Get.offAllNamed(AppRoutes.forgotPassword);
      return;
    }

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.sendForgotPasswordOtp(
            mobile: mobile,
          );
          if (result.isSuccess) {
            forgotPasswordOtp.value = '';
            showSuccessMessage(
              message: 'A new verification code has been sent',
            );
            _startForgotPasswordResendCountdown();
          } else {
            showErrorMessage(
              message: result.message ?? 'Failed to resend code',
            );
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  RxBool canResendForgotPasswordOtp = false.obs;
  RxInt forgotPasswordResendCountdown = 30.obs;
  Timer? _forgotPasswordResendTimer;

  /// Start forgot password resend countdown timer
  void _startForgotPasswordResendCountdown() {
    canResendForgotPasswordOtp.value = false;
    forgotPasswordResendCountdown.value = 30;

    _forgotPasswordResendTimer?.cancel();
    _forgotPasswordResendTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (forgotPasswordResendCountdown.value > 0) {
        forgotPasswordResendCountdown.value--;
      } else {
        canResendForgotPasswordOtp.value = true;
        timer.cancel();
      }
    });
  }

  String _normalizeMobile(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    // Keep digits and plus; collapse local 10-digit numbers to +91 format.
    final sanitized = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    if (sanitized.startsWith('+')) {
      return '+${sanitized.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }

    final digits = sanitized.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+91$digits';
    }

    if (digits.length >= 8 && digits.length <= 15) {
      return '+$digits';
    }

    return digits;
  }
}
