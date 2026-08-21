import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:estoriz/features/watchlist/presentation/controllers/watchlist_controller.dart';
import 'package:toastification/toastification.dart';
import 'core/bindings/splash_binding.dart';
import 'core/routes/get_pages.dart';
import 'core/services/notification_services.dart';
import 'core/theme/app_theme.dart';
import 'package:estoriz/features/video_player/view/global_mini_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();
  await GetStorage.init('loginData');
  await GetStorage.init('baseUrl');
  await GetStorage.init('onboardingVal');
  try {
    await Get.putAsync(() => NotificationService().init(), permanent: true);
  } catch (e) {
    Get.put(NotificationService(), permanent: true);
  }

  // Keep watchlist state alive across screens for instant icon updates.
  Get.put<WatchlistController>(WatchlistController(), permanent: true);

  final bool isDarkMode = GetStorage().read<bool>('isDarkMode') ?? true;

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MyApp(initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: GetMaterialApp(
            title: 'Estoriz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: initialThemeMode,
            // GetX Navigation
            initialRoute: PageRoutes.initial,
            initialBinding: SplashBinding(),
            getPages: PageRoutes.routes,

            // Unknown route fallback
            unknownRoute: GetPage(
              name: '/notfound',
              page: () => const Scaffold(
                body: Center(
                  child: Text(
                    '404 - Page Not Found',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Default transition
            defaultTransition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 300),
            builder: (context, child) {
              return Stack(children: [child!, const GlobalMiniPlayer()]);
            },
          ),
        );
      },
    );
  }
}
