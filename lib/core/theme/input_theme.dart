import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

/// Input/Form Theme Configuration for OTT App
///
/// Includes themes for text fields, checkboxes, switches, sliders, and radios.
class AppInputTheme {
  AppInputTheme._();

  // ============================================
  // INPUT DECORATION THEME
  // ============================================

  /// Text field decoration theme
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,

    // Content padding
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

    // Border styles
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.outline, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.outline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.outline.withValues(alpha: 0.38),
        width: 1,
      ),
    ),

    // Text styles
    hintStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textHint,
    ),
    labelStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    errorStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.error,
    ),
    helperStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    prefixStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    suffixStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    counterStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),

    // Icon colors
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,

    // Other properties
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    isDense: false,
    alignLabelWithHint: true,
  );

  // ============================================
  // CHECKBOX THEME
  // ============================================

  /// Checkbox theme
  static CheckboxThemeData get checkboxTheme => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      if (states.contains(WidgetState.disabled)) {
        return AppColors.outline.withValues(alpha: 0.38);
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.12)),
    splashRadius: 20.r,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    side: BorderSide(color: AppColors.outline, width: 2),
    visualDensity: VisualDensity.standard,
  );

  // ============================================
  // SWITCH THEME
  // ============================================

  /// Switch theme
  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.onPrimary;
      }
      return AppColors.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.outline;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return AppColors.outline;
    }),
    overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.12)),
    splashRadius: 20.r,
  );

  // ============================================
  // RADIO THEME
  // ============================================

  /// Radio button theme
  static RadioThemeData get radioTheme => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      if (states.contains(WidgetState.disabled)) {
        return AppColors.outline.withValues(alpha: 0.38);
      }
      return AppColors.outline;
    }),
    overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.12)),
    splashRadius: 20.r,
    visualDensity: VisualDensity.standard,
  );

  // ============================================
  // SLIDER THEME
  // ============================================

  /// Slider theme
  static SliderThemeData get sliderTheme => SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.outline,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withValues(alpha: 0.12),
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.onPrimary,
    ),
    trackHeight: 4.h,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 20.r),
    tickMarkShape: RoundSliderTickMarkShape(),
    activeTickMarkColor: AppColors.onPrimary,
    inactiveTickMarkColor: AppColors.textSecondary,
    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
    showValueIndicator: ShowValueIndicator.always,
  );

  // ============================================
  // PROGRESS INDICATOR THEME
  // ============================================

  /// Progress indicator theme
  static ProgressIndicatorThemeData get progressIndicatorTheme =>
      ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.outline,
        linearTrackColor: AppColors.outline,
        refreshBackgroundColor: AppColors.surface,
      );
}


