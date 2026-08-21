import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'button_theme.dart';
import 'input_theme.dart';
import 'component_theme.dart';

/// Main App Theme Configuration
///
/// Provides app themes for the OTT app.
/// Usage: theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme
///
/// Note: For text widgets, use ResponsiveText from lib/common/responsive_text.dart
/// Example: ResponsiveText.title("Dashboard"), ResponsiveText.bodyMedium("Content")
class AppTheme {
  AppTheme._();

  /// Default font family for the app
  static const String fontFamily = 'Montserrat';

  /// Minimal text theme with white colors for Flutter's internal widgets
  /// For custom text, use ResponsiveText widget instead
  static TextTheme get _minimalTextTheme => const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    headlineLarge: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    headlineMedium: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    headlineSmall: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    titleLarge: TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily),
    titleMedium: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily),
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily),
    bodyMedium: TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily),
    bodySmall: TextStyle(
      color: AppColors.textSecondary,
      fontFamily: fontFamily,
    ),
    labelLarge: TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily),
    labelMedium: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: fontFamily,
    ),
    labelSmall: TextStyle(
      color: AppColors.textSecondary,
      fontFamily: fontFamily,
    ),
  );

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
    // Base configuration
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,

    // ============================================
    // COLOR SCHEME
    // ============================================
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      // Primary colors
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,

      // Secondary colors
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,

      // Tertiary colors
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onPrimary,

      // Error colors
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,

      // Surface colors
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,

      // Other colors
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.primaryLight,
    ),

    // ============================================
    // SCAFFOLD & BACKGROUND
    // ============================================
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    splashColor: AppColors.primary.withValues(alpha: 0.12),
    highlightColor: AppColors.primary.withValues(alpha: 0.08),
    hoverColor: AppColors.primary.withValues(alpha: 0.04),
    focusColor: AppColors.primary.withValues(alpha: 0.12),

    // ============================================
    // TYPOGRAPHY (minimal - use ResponsiveText for custom text)
    // ============================================
    textTheme: _minimalTextTheme,
    primaryTextTheme: _minimalTextTheme,

    // ============================================
    // BUTTON THEMES
    // ============================================
    elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
    textButtonTheme: AppButtonTheme.textButtonTheme,
    outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
    iconButtonTheme: AppButtonTheme.iconButtonTheme,
    floatingActionButtonTheme: AppButtonTheme.floatingActionButtonTheme,
    filledButtonTheme: AppButtonTheme.filledButtonTheme,

    // ============================================
    // INPUT THEMES
    // ============================================
    inputDecorationTheme: AppInputTheme.inputDecorationTheme,
    checkboxTheme: AppInputTheme.checkboxTheme,
    switchTheme: AppInputTheme.switchTheme,
    radioTheme: AppInputTheme.radioTheme,
    sliderTheme: AppInputTheme.sliderTheme,
    progressIndicatorTheme: AppInputTheme.progressIndicatorTheme,

    // ============================================
    // COMPONENT THEMES
    // ============================================
    appBarTheme: AppComponentTheme.appBarTheme,
    cardTheme: AppComponentTheme.cardTheme,
    dialogTheme: AppComponentTheme.dialogTheme,
    bottomSheetTheme: AppComponentTheme.bottomSheetTheme,
    tabBarTheme: AppComponentTheme.tabBarTheme,
    chipTheme: AppComponentTheme.chipTheme,
    bottomNavigationBarTheme: AppComponentTheme.bottomNavigationBarTheme,
    navigationBarTheme: AppComponentTheme.navigationBarTheme,
    snackBarTheme: AppComponentTheme.snackBarTheme,
    dividerTheme: AppComponentTheme.dividerTheme,
    iconTheme: AppComponentTheme.iconTheme,
    primaryIconTheme: AppComponentTheme.primaryIconTheme,
    drawerTheme: AppComponentTheme.drawerTheme,
    listTileTheme: AppComponentTheme.listTileTheme,
    tooltipTheme: AppComponentTheme.tooltipTheme,
    popupMenuTheme: AppComponentTheme.popupMenuTheme,
    expansionTileTheme: AppComponentTheme.expansionTileTheme,
    badgeTheme: AppComponentTheme.badgeTheme,
    scrollbarTheme: AppComponentTheme.scrollbarTheme,

    // ============================================
    // SYSTEM UI OVERLAY
    // ============================================
    applyElevationOverlayColor: false,

    // ============================================
    // VISUAL DENSITY
    // ============================================
    visualDensity: VisualDensity.standard,

    // ============================================
    // MATERIAL TAP TARGET SIZE
    // ============================================
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // ============================================
    // PAGE TRANSITIONS
    // ============================================
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFF111827),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  /// System UI overlay style for the app (dark status bar icons)
  static SystemUiOverlayStyle get systemUiOverlayStyle =>
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.scaffoldBackground,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      );
}
