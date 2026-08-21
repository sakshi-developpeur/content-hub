import 'dart:async';
import 'package:estoriz/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/auth/service/auth_service.dart';

import '../../../core/services/notification_services.dart';
import '../../../models/auth_response_model.dart';

class AuthController extends BaseController {
  final AuthService _authService = Get.find<AuthService>();
  final UserData _userData = UserData();
  Map<String, dynamic>? _pendingPostLoginVideoArgs;

  @override
  void onInit() {
    super.onInit();
    _syncPendingPostLoginVideoArgs();
  }

  // Form controllers
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// login textediting controllers
  final TextEditingController loginIdentifierController =
      TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  // Observable states
  final RxBool agreeToTerms = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoggedIn = false.obs;

  // OTP related states (for login OTP)
  final RxString currentOtp = ''.obs;
  final RxString loginOtpEmail = ''.obs;
  final RxBool canResendOtp = false.obs;
  final RxInt resendCountdown = 30.obs;
  Timer? _resendTimer;
  AuthResponseModel? _pendingLoginResponse;

  /// Masked identifier (email or phone) for display
  String get maskedLoginIdentifier => _maskIdentifier(loginOtpEmail.value);
  String get loginOtpTargetLabel =>
      GetUtils.isEmail(loginOtpEmail.value.trim()) ? 'email' : 'phone number';

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  void _syncPendingPostLoginVideoArgs() {
    _pendingPostLoginVideoArgs = null;

    final args = Get.arguments;
    if (args is! Map) return;

    final rawVideoArgs = args['postLoginVideoArgs'];
    if (rawVideoArgs is Map) {
      _pendingPostLoginVideoArgs = Map<String, dynamic>.from(rawVideoArgs);
    }
  }

  /// Toggle terms agreement checkbox
  void toggleAgreeToTerms(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  /// Toggle remember me checkbox
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  /// Navigate to sign up screen
  void goToSignUp() {
    _clearFields();
    Get.toNamed(AppRoutes.signUp);
  }

  /// Navigate to login screen
  void goToLogin() {
    _clearFields();
    Get.toNamed(AppRoutes.login);
  }

  /// Navigate to forgot password screen
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void openTermsConditions() {
    Get.toNamed(AppRoutes.termsConditions);
  }

  Future<bool> checkLoginStatus() async {
    final loggedIn = await _userData.checkLoginStatus();
    isLoggedIn.value = loggedIn;
    return loggedIn;
  }

  /// Handle login
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    final identifier = loginIdentifierController.text.trim();
    final password = loginPasswordController.text.trim();

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.login(
            identifier: identifier,
            password: password,
          );

          if (result.isSuccess) {
            _pendingLoginResponse = result.data;
            loginOtpEmail.value = identifier;
            currentOtp.value = '';
            _startResendCountdown();
            Get.toNamed(AppRoutes.otpVerification);
          } else {
            showErrorMessage(message: result.message ?? 'Login failed');
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Handle sign up
  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;

    if (!agreeToTerms.value) {
      showWarningMessage(
        message: 'Please agree to the terms of services and privacy policy',
      );
      return;
    }

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.register(
            username: usernameController.text.trim(),
            email: identifierController.text.trim(),
            password: passwordController.text.trim(),
            phone: phoneController.text.trim(),
          );

          if (result.isSuccess && result.data != null) {
            // Ensure phone is preserved if API doesn't return it
            final phone = phoneController.text.trim();
            final authData = result.data!;
            if (authData.user != null &&
                (authData.user!.phone == null ||
                    authData.user!.phone!.isEmpty)) {
              // Create a new user model with the phone number
              final updatedUser = UserModel(
                id: authData.user!.id,
                email: authData.user!.email,
                name: authData.user!.name,
                role: authData.user!.role,
                subscriptionStatus: authData.user!.subscriptionStatus,
                twoFAEnabled: authData.user!.twoFAEnabled,
                phone: phone,
                avatar: authData.user!.avatar,
                authProviders: authData.user!.authProviders,
              );
              final updatedAuthData = AuthResponseModel(
                accessToken: authData.accessToken,
                refreshToken: authData.refreshToken,
                expiresIn: authData.expiresIn,
                deviceId: authData.deviceId,
                user: updatedUser,
              );
              _userData.saveLoginData(updatedAuthData);
            } else {
              _userData.saveLoginData(authData);
            }

            await _userData.setLoggedIn(true);
            isLoggedIn.value = true;
            NotificationService.instance.setExternalUserId(
              result.data!.user?.id ?? '',
            );
            //showSuccessMessage(message: 'Account created successfully!');
            Get.offAllNamed(AppRoutes.profileSelection);
          } else {
            final rawMessage = (result.message ?? '').trim();
            final normalizedMessage = rawMessage.toLowerCase();
            final isEmailAlreadyRegistered =
                result.statusCode == 409 ||
                normalizedMessage == 'oops something went wrong' ||
                normalizedMessage == 'something went wrong';

            showErrorMessage(
              message: isEmailAlreadyRegistered
                  ? 'This email is already registered'
                  : (rawMessage.isNotEmpty ? rawMessage : 'Sign up failed'),
            );
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Handle Google sign in
  Future<void> signInWithGoogle() async {
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final googleSignIn = GoogleSignIn(
            scopes: ['email', 'profile'],
            clientId:
                "529363753030-2psh1hktvto9ffs7mg4uucdkjtljnfkl.apps.googleusercontent.com",
            serverClientId:
                '529363753030-baleme0v340i0ps8dk0kggknoehg8g6e.apps.googleusercontent.com',
          );

          await googleSignIn.signOut();

          final account = await googleSignIn.signIn();
          if (account == null) {
            // User cancelled
            return;
          }

          final authentication = await account.authentication;
          final idToken = authentication.idToken;

          if (idToken == null || idToken.isEmpty) {
            showErrorMessage(
              message: 'Failed to get Google authentication token',
            );
            return;
          }

          final deviceInfo = await _collectDeviceInfo();
          final result = await _authService.googleLogin(
            idToken: idToken,
            deviceInfo: deviceInfo,
          );

          if (result.isSuccess && result.data != null) {
            _handleSocialLoginSuccess(result.data!);
          } else {
            showErrorMessage(
              message: result.message ?? 'Google sign in failed',
            );
          }
        } catch (e) {
          showErrorMessage(message: 'Google sign in failed: ${e.toString()}');
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Handle Apple sign in (iOS only)
  Future<void> signInWithApple() async {
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

          final identityToken = credential.identityToken;
          if (identityToken == null || identityToken.isEmpty) {
            showErrorMessage(
              message: 'Failed to get Apple authentication token',
            );
            return;
          }

          final deviceInfo = await _collectDeviceInfo();
          final result = await _authService.appleLogin(
            identityToken: identityToken,
            deviceInfo: deviceInfo,
          );

          if (result.isSuccess && result.data != null) {
            _handleSocialLoginSuccess(result.data!);
          } else {
            showErrorMessage(message: result.message ?? 'Apple sign in failed');
          }
        } catch (e) {
          showErrorMessage(message: 'Apple sign in failed: ${e.toString()}');
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Common handler for successful social login (Google/Apple).
  void _handleSocialLoginSuccess(AuthResponseModel authResponse) {
    _userData.saveLoginData(authResponse);
    _userData.setLoggedIn(true);
    isLoggedIn.value = true;
    NotificationService.instance.setExternalUserId(authResponse.user?.id ?? '');

    final pendingVideoArgs = _pendingPostLoginVideoArgs;
    _pendingPostLoginVideoArgs = null;
    _clearFields();

    if (pendingVideoArgs != null) {
      Get.offNamedUntil(
        AppRoutes.videoPlayer,
        (route) => route.settings.name == AppRoutes.dashboard,
        arguments: pendingVideoArgs,
      );
    } else {
      Get.offAllNamed(AppRoutes.profileSelection);
    }
  }

  /// Collect device info for OAuth API calls.
  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await deviceInfoPlugin.androidInfo;
        return {
          'deviceType': 'mobile',
          'osVersion': 'Android ${android.version.release}',
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await deviceInfoPlugin.iosInfo;
        return {
          'deviceType': 'mobile',
          'osVersion': 'iOS ${ios.systemVersion}',
        };
      }
    } catch (_) {
      // Fallback silently
    }
    return {'deviceType': 'mobile', 'osVersion': 'unknown'};
  }

  /// Handle fingerprint authentication
  Future<void> authenticateWithFingerprint() async {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  // ============================================
  // OTP VERIFICATION METHODS (Login)
  // ============================================

  /// Called when OTP input changes
  void onOtpChanged(String otp) {
    currentOtp.value = otp;
  }

  /// Called when OTP input is completed
  void onOtpCompleted(String otp) {
    currentOtp.value = otp;
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (currentOtp.value.length != 6) {
      showWarningMessage(message: 'Please enter the complete 6-digit code');
      return;
    }

    final identifier = loginOtpEmail.value.trim();
    if (identifier.isEmpty) {
      showErrorMessage(message: 'Login session expired. Please sign in again.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.verifyLoginOtp(
            identifier: identifier,
            otp: currentOtp.value,
            deviceInfo: _buildDeviceInfo(),
          );

          if (result.isSuccess) {
            final authResponse = _resolveVerifiedAuthResponse(result.data);
            if (authResponse == null) {
              showErrorMessage(
                message:
                    'Verification succeeded but no login data was returned.',
              );
              return;
            }

            _userData.saveLoginData(authResponse);
            await _userData.setLoggedIn(true);
            isLoggedIn.value = true;
            NotificationService.instance.setExternalUserId(
              authResponse.user?.id ?? '',
            );
            //showSuccessMessage(message: 'Verification successful!');
            final pendingVideoArgs = _pendingPostLoginVideoArgs;
            _pendingPostLoginVideoArgs = null;
            _clearLoginOtpState(clearCredentials: true);
            if (pendingVideoArgs != null) {
              Get.offNamedUntil(
                AppRoutes.videoPlayer,
                (route) => route.settings.name == AppRoutes.dashboard,
                arguments: pendingVideoArgs,
              );
            } else {
              Get.offAllNamed(AppRoutes.profileSelection);
            }
          } else {
            final message = _resolveOtpErrorMessage(result.message);
            if (result.statusCode == 401) {
              _resendTimer?.cancel();
              canResendOtp.value = true;
              resendCountdown.value = 0;
            }
            showErrorMessage(message: message);
          }
        } finally {
          setLoadingState(false);
        }
      },
    );
  }

  /// Resend OTP code
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    final identifier = loginOtpEmail.value.trim();
    final password = loginPasswordController.text.trim();
    if (identifier.isEmpty || password.isEmpty) {
      showErrorMessage(message: 'Login session expired. Please sign in again.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        setLoadingState(true);
        try {
          final result = await _authService.login(
            identifier: identifier,
            password: password,
          );

          if (result.isSuccess) {
            _pendingLoginResponse = result.data ?? _pendingLoginResponse;
            currentOtp.value = '';
            showSuccessMessage(
              message: 'A new verification code has been sent',
            );
            _startResendCountdown();
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

  Future<void> logout() async {
    try {
      setLoadingState(true);
      await _userData.clearAllUserData();
      isLoggedIn.value = false;
      showSuccessMessage(message: 'Signed out successfully');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      showErrorMessage(message: 'Logout failed: ${e.toString()}');
    } finally {
      setLoadingState(false);
    }
  }

  /// Start resend countdown timer
  void _startResendCountdown() {
    canResendOtp.value = false;
    resendCountdown.value = 30;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  /// Clear all form fields
  void _clearFields() {
    identifierController.clear();
    passwordController.clear();
    usernameController.clear();
    agreeToTerms.value = false;
    _clearLoginOtpState(clearCredentials: false);
  }

  void _clearLoginOtpState({required bool clearCredentials}) {
    currentOtp.value = '';
    loginOtpEmail.value = '';
    _pendingLoginResponse = null;
    _resendTimer?.cancel();
    canResendOtp.value = false;
    resendCountdown.value = 30;

    if (clearCredentials) {
      loginIdentifierController.clear();
      loginPasswordController.clear();
    }
  }

  AuthResponseModel? _resolveVerifiedAuthResponse(AuthResponseModel? response) {
    if (response != null) {
      final hasToken = (response.accessToken ?? '').isNotEmpty;
      final hasUser = response.user != null;
      if (hasToken || hasUser) {
        return response;
      }
    }

    if (_pendingLoginResponse != null) {
      final hasToken = (_pendingLoginResponse!.accessToken ?? '').isNotEmpty;
      final hasUser = _pendingLoginResponse!.user != null;
      if (hasToken || hasUser) {
        return _pendingLoginResponse;
      }
    }

    return response;
  }

  Map<String, dynamic> _buildDeviceInfo() {
    final platform = kIsWeb ? 'web' : defaultTargetPlatform.name;

    return {'platform': platform, 'source': 'flutter_app'};
  }

  String _resolveOtpErrorMessage(String? rawMessage) {
    final message = (rawMessage ?? '').trim();
    if (message.isEmpty) {
      return 'Invalid or expired OTP';
    }

    final normalized = message.toLowerCase();
    if (normalized.contains('invalid') || normalized.contains('expired')) {
      return 'Invalid or expired OTP';
    }

    return message;
  }

  String _maskEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return trimmed;
    }

    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return trimmed;
    }

    final localPart = parts.first;
    final domain = parts.last;
    if (localPart.length <= 2) {
      return '${localPart.substring(0, 1)}***@$domain';
    }

    return '${localPart.substring(0, 2)}***@$domain';
  }

  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;

    final visible = digits.substring(digits.length - 4);
    return '******$visible';
  }

  String _maskIdentifier(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return trimmed;

    if (GetUtils.isEmail(trimmed)) {
      return _maskEmail(trimmed);
    }

    return _maskPhone(trimmed);
  }

  /// Email or phone validator
  String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or phone is required';
    }

    // Email check
    if (GetUtils.isEmail(value)) {
      return null;
    }

    // Phone number check
    if (GetUtils.isPhoneNumber(value)) {
      return null;
    }

    return 'Enter valid email or phone number';
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Phone number check
    if (GetUtils.isPhoneNumber(value)) {
      return null;
    }

    return 'Enter valid phone number';
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

  /// Username validator
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }
}
