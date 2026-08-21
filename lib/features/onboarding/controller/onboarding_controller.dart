import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/user_data.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final int totalPages = 3;

  final UserData _userData = UserData();

  /// List of onboarding content data
  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Numerous free trial courses',
      'description': 'Free courses for you to find your way to learning',
    },
    {
      'title': 'Quick and easy learning',
      'description':
          'Easy and fast learning at any time to help you improve various skills',
    },
    {
      'title': 'Create your own study plan',
      'description':
          'Study according to the study plan, make study more motivated',
    },
  ];

  /// Check if current page is the last page
  bool get isLastPage => currentPage.value == totalPages - 1;

  /// Check if current page is the first page
  bool get isFirstPage => currentPage.value == 0;

  /// Navigate to next page
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  /// Update current page from page controller
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  /// Skip onboarding and navigate to login
  void skip() {
    _completeOnboarding();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navigate to login screen
  void goToLogin() {
    _completeOnboarding();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navigate to signup screen
  void goToSignUp() {
    _completeOnboarding();
    Get.offAllNamed(AppRoutes.signUp);
  }

  /// Mark onboarding as completed
  void _completeOnboarding() {
    _userData.setOnboardingScreen(1);
  }
}

