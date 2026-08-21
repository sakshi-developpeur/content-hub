import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/responsive_text.dart';
import '../../../common/app_button.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Background image placeholder - replace with your image
          color: AppColors.scaffoldBackground,
          // Uncomment below when you have background image:
          image: DecorationImage(
            image: AssetImage(AppConstant.onboardingBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with logo and skip button
              _buildTopBar(),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: controller.totalPages,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      bannerImage: _getBannerImage(index),
                      title: controller.onboardingData[index]['title']!,
                      description:
                          controller.onboardingData[index]['description']!,
                    );
                  },
                ),
              ),

              // Page indicator
              Obx(
                () => PageIndicator(
                  currentPage: controller.currentPage.value,
                  totalPages: controller.totalPages,
                ),
              ),

              SizedBox(height: 24.h),

              // Bottom buttons
              Obx(() => _buildBottomButtons(pageController)),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: AppPaddings.symmetric(h: 20, v: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            AppConstant.appLogo,
            height: 40.h,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.all(8),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.onPrimary,
                  size: 24.w,
                ),
              );
            },
          ),

          // Skip button (hide on last page)
          Obx(
            () => controller.isLastPage
                ? const SizedBox()
                : GestureDetector(
                    onTap: controller.skip,
                    child: ResponsiveText.bodyMedium(
                      'Skip',
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(PageController pageController) {
    if (controller.isLastPage) {
      // Last page - show Sign Up and Login buttons
      return Padding(
        padding: AppPaddings.symmetric(h: 20),
        child: Row(
          children: [
            Expanded(
              child: AppButton.primary(
                text: 'Sign up',
                onPressed: controller.goToSignUp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AppButton.outlined(
                text: 'Log in',
                onPressed: controller.goToLogin,
              ),
            ),
          ],
        ),
      );
    } else {
      // Other pages - show Previous (if not first) and Next buttons
      return Padding(
        padding: AppPaddings.symmetric(h: 20),
        child: Row(
          children: [
            if (!controller.isFirstPage) ...[
              Expanded(
                child: AppButton.outlined(
                  text: 'Previous',
                  onPressed: () {
                    controller.previousPage();
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: AppButton.primary(
                text: 'Next',
                onPressed: () {
                  controller.nextPage();
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getBannerImage(int index) {
    switch (index) {
      case 0:
        return AppConstant.onBoradingBanner1;
      case 1:
        return AppConstant.onBoradingBanner2;
      case 2:
        return AppConstant.onBoradingBanner3;
      default:
        return AppConstant.onBoradingBanner1;
    }
  }
}
