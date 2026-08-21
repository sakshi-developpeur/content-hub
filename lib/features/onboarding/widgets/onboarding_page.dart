import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/responsive_text.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';

/// Individual onboarding page widget
class OnboardingPage extends StatelessWidget {
  final String bannerImage;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.bannerImage,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.symmetric(h: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Banner image
          Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(
                bannerImage,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder when image is not available
                  return Container(
                    width: 280.w,
                    height: 280.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadius.all(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 80.w,
                          color: AppColors.textDisabled,
                        ),
                        SizedBox(height: 16.h),
                        ResponsiveText.bodySmall(
                          'Image placeholder',
                          color: AppColors.textDisabled,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Title
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: AppPaddings.symmetric(h: 40),
                  child: ResponsiveText.title(
                    title,

                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 16.h),

                // Description
                Padding(
                  padding: AppPaddings.symmetric(h: 40),
                  child: ResponsiveText.bodyMedium(
                    description,
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

