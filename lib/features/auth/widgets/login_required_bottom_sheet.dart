import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/common/app_button.dart';
import 'package:estoriz/common/responsive_text.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/core/value/dimension.dart';

class LoginRequiredBottomSheet extends StatelessWidget {
  const LoginRequiredBottomSheet({super.key, required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            ResponsiveText.title(
              'Login Required',
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            ResponsiveText.bodyMedium(
              'Please login to continue and play this video.',
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            AppButton.primary(text: 'Login', onPressed: onLoginPressed),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: AppPaddings.symmetric(v: 14),
              ),
              child: ResponsiveText.bodyMedium(
                'Not now',
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
