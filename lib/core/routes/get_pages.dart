import 'package:estoriz/features/livestreaming/presentation/views/livestreaming_view.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/routes/auth_middleware.dart';
import 'package:estoriz/core/bindings/splash_binding.dart';
import 'package:estoriz/core/bindings/onboarding_binding.dart';
import 'package:estoriz/core/bindings/auth_binding.dart';
import 'package:estoriz/features/splash/view/splash_view.dart';
import 'package:estoriz/features/onboarding/view/onboarding_view.dart';
import 'package:estoriz/features/auth/view/login_view.dart';
import 'package:estoriz/features/auth/view/signup_view.dart';
import 'package:estoriz/features/auth/view/otp_verification_view.dart';
import 'package:estoriz/features/auth/forgot_password/view/forgot_password_view.dart';
import 'package:estoriz/features/auth/forgot_password/view/forgot_password_otp_view.dart';
import 'package:estoriz/features/auth/forgot_password/view/change_password_view.dart';
import 'package:estoriz/features/auth/forgot_password/view/password_changed_success_view.dart';

import 'package:estoriz/core/bindings/forgot_password_binding.dart';
import 'package:estoriz/core/bindings/profile_selection_binding.dart';
import 'package:estoriz/features/profile/view/create_profile_view.dart';
import 'package:estoriz/features/profile/view/profile_selection_view.dart';
import 'package:estoriz/core/bindings/dashboard_binding.dart';
import 'package:estoriz/core/bindings/category_details_binding.dart';
import 'package:estoriz/core/bindings/subscription_binding.dart';
import 'package:estoriz/core/bindings/video_list_binding.dart';
import 'package:estoriz/core/bindings/video_player_binding.dart';
import 'package:estoriz/features/dashboard/view/dashboard_view.dart';
import 'package:estoriz/features/home/presentation/views/category_details_view.dart';
import 'package:estoriz/features/subscription/view/subscription_view.dart';
import 'package:estoriz/features/home/presentation/views/video_list_view.dart';
import 'package:estoriz/features/video_player/view/video_player_view.dart';
import 'package:estoriz/features/watchlist/view/watchlist_view.dart';
import 'package:estoriz/features/watchlist/presentation/bindings/watchlist_binding.dart';
import 'package:estoriz/features/home/presentation/views/announcement_details_view.dart';
import 'package:estoriz/features/watch_history/presentation/bindings/watch_history_binding.dart';
import 'package:estoriz/features/watch_history/presentation/views/watch_history_view.dart';
import 'package:estoriz/core/bindings/settings_binding.dart';
import 'package:estoriz/features/settings/view/settings_view.dart';
import 'package:estoriz/features/settings/view/downloads_view.dart';
import 'package:estoriz/features/settings/view/about_us_view.dart';
import 'package:estoriz/features/settings/view/contact_us_view.dart';
import 'package:estoriz/features/livestreaming/presentation/bindings/livestreaming_binding.dart';
import 'package:estoriz/features/livestreaming/presentation/views/live_player_view.dart';
import 'package:estoriz/features/livestreaming/presentation/bindings/live_player_binding.dart';
import 'package:estoriz/features/settings/view/privacy_policy_view.dart';
import 'package:estoriz/features/settings/view/terms_conditions_view.dart';
import 'package:estoriz/features/profile/view/user_profile_view.dart';
import 'package:estoriz/core/bindings/user_profile_binding.dart';

import '../../features/home/presentation/views/see_all_view.dart';

class PageRoutes {
  static const initial = AppRoutes.splash;
  static const leftToRightTransition = Transition.leftToRight;
  static const fadeInTransition = Transition.fadeIn;

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      transition: fadeInTransition,
      binding: SplashBinding(),
    ),

    // See All Screen
    GetPage(
      name: AppRoutes.seeAll,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final type = (args != null && args['type'] == 'categories')
            ? SeeAllType.categories
            : SeeAllType.newOnEstoriz;
        return SeeAllView(type: type);
      },
    ),

    // Onboarding Screen
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      transition: leftToRightTransition,
      binding: OnboardingBinding(),
    ),

    // Login Screen
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      transition: leftToRightTransition,
      binding: AuthBinding(),
    ),

    // Sign Up Screen
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpView(),
      transition: leftToRightTransition,
      binding: AuthBinding(),
    ),

    // OTP Verification Screen
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationView(),
      transition: leftToRightTransition,
      binding: AuthBinding(),
    ),

    // Forgot Password Screen
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      transition: leftToRightTransition,
      binding: ForgotPasswordBinding(),
    ),

    // Forgot Password OTP Screen
    GetPage(
      name: AppRoutes.forgotPasswordOtp,
      page: () => const ForgotPasswordOtpView(),
      transition: leftToRightTransition,
      binding: ForgotPasswordBinding(),
    ),

    // Change Password Screen
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      transition: leftToRightTransition,
      binding: ForgotPasswordBinding(),
    ),

    // Password Changed Success Screen
    GetPage(
      name: AppRoutes.passwordChangedSuccess,
      page: () => const PasswordChangedSuccessView(),
      transition: leftToRightTransition,
      binding: ForgotPasswordBinding(),
    ),

    // Profile Selection Screen
    GetPage(
      name: AppRoutes.profileSelection,
      page: () => const ProfileSelectionView(),
      transition: leftToRightTransition,
      binding: ProfileSelectionBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.createProfile,
      page: () => const CreateProfileView(),
      transition: leftToRightTransition,
      binding: ProfileSelectionBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Dashboard Screen
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      transition: fadeInTransition,
      binding: DashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.categoryDetails,
      page: () => const CategoryDetailsView(),
      transition: leftToRightTransition,
      binding: CategoryDetailsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.videoList,
      page: () => const VideoListView(),
      transition: leftToRightTransition,
      binding: VideoListBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Video Player Screen
    GetPage(
      name: AppRoutes.videoPlayer,
      page: () => const VideoPlayerView(),
      transition: leftToRightTransition,
      binding: VideoPlayerBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Watchlist Screen
    GetPage(
      name: AppRoutes.watchlist,
      page: () => const WatchlistView(),
      transition: leftToRightTransition,
      binding: WatchlistBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Watch History Screen
    GetPage(
      name: AppRoutes.watchHistory,
      page: () => const WatchHistoryView(),
      transition: leftToRightTransition,
      binding: WatchHistoryBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionView(),
      transition: leftToRightTransition,
      binding: SubscriptionBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Announcement Details Screen
    GetPage(
      name: AppRoutes.announcementDetails,
      page: () => const AnnouncementDetailsView(),
      transition: leftToRightTransition,
      middlewares: [AuthMiddleware()],
    ),

    // Settings Screen
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      transition: leftToRightTransition,
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // My Downloads Screen
    GetPage(
      name: AppRoutes.myDownloads,
      page: () => const DownloadsView(),
      transition: leftToRightTransition,
      middlewares: [AuthMiddleware()],
    ),

    // About Us Screen
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsView(),
      transition: leftToRightTransition,
      middlewares: [AuthMiddleware()],
    ),

    // Contact Us Screen
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const ContactUsView(),
      transition: leftToRightTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.live,
      page: () => const LivestreamingView(),
      transition: leftToRightTransition,
      binding: LivestreamingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.livePlayer,
      page: () => const LivePlayerView(),
      transition: leftToRightTransition,
      binding: LivePlayerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
      transition: leftToRightTransition,
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsView(),
      transition: leftToRightTransition,
    ),
    GetPage(
      name: AppRoutes.profileView,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
      transition: leftToRightTransition,
    ),
  ];
}
