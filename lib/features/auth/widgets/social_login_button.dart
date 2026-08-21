import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/constants/app_constant.dart';
import '../../../common/responsive_text.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';

/// Social login button widget for Google and Apple sign-in.
class SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.textColor = AppColors.textPrimary,
  });

  /// Google sign in button
  factory SocialLoginButton.google({required VoidCallback? onPressed}) {
    return SocialLoginButton(
      text: 'Sign in with Google',
      icon: Image.asset(
        AppConstant.googleIcon,
        height: 24,
        width: 24,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
    );
  }

  /// Apple sign in button (shown only on iOS)
  factory SocialLoginButton.apple({required VoidCallback? onPressed}) {
    return SocialLoginButton(
      text: 'Sign in with Apple',
      icon: const Icon(Icons.apple, color: Colors.white, size: 24),
      onPressed: onPressed,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  /// Returns true if Apple Sign-In should be shown (iOS only).
  static bool get showApple => Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: AppColors.onSurface, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(16)),
          padding: AppPaddings.symmetric(h: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 12.w),
            ResponsiveText.bodyMedium(
              text,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
