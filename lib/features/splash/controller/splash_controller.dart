import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/user_data.dart';

import 'package:package_info_plus/package_info_plus.dart';

class SplashController extends GetxController {
  final UserData _userData = UserData();
  final RxString appVersion = '...'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    _navigateToNextScreen();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value =
          'Version ${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      appVersion.value = 'Version 1.0.0';
    }
  }

  Future<void> _navigateToNextScreen() async {
    print("Navigating to next screen...");
    // Simulate loading time for splash animation
    await Future.delayed(const Duration(seconds: 3));

    // Check if onboarding has been completed
    final hasSeenOnboarding = _userData.getOnboardingVal == 1;

    if (hasSeenOnboarding) {
      // Use SharedPreferences as the authoritative login flag because
      // GetStorage disk writes are debounced and may not flush before the
      // app is killed after logout, causing stale token reads on restart.
      final isLoggedIn = await _userData.checkLoginStatus();
      final accessToken = UserData().getLoginData.accessToken;
      if (isLoggedIn && accessToken != null && accessToken.isNotEmpty) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
