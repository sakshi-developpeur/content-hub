import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

/// Button Theme Configuration for OTT App
///
/// Includes themes for all button types with primary color (#543EE9).
class AppButtonTheme {
  AppButtonTheme._();

  // ============================================
  // ELEVATED BUTTON THEME
  // ============================================

  /// Primary elevated button style - used for main CTAs
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.38),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          minimumSize: Size(64.w, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );

  // ============================================
  // TEXT BUTTON THEME
  // ============================================

  /// Text button style - used for less prominent actions
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.primary.withValues(alpha: 0.38),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      minimumSize: Size(48.w, 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    ),
  );

  // ============================================
  // OUTLINED BUTTON THEME
  // ============================================

  /// Outlined button style - bordered buttons
  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.primary.withValues(alpha: 0.38),
          side: BorderSide(color: AppColors.primary, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          minimumSize: Size(64.w, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );

  // ============================================
  // ICON BUTTON THEME
  // ============================================

  /// Icon button style
  static IconButtonThemeData get iconButtonTheme => IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      disabledForegroundColor: AppColors.textDisabled,
      highlightColor: AppColors.primary.withValues(alpha: 0.1),
      padding: EdgeInsets.all(8.w),
      minimumSize: Size(40.w, 40.h),
      iconSize: 24.w,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    ),
  );

  // ============================================
  // FLOATING ACTION BUTTON THEME
  // ============================================

  /// FAB style with primary color
  static FloatingActionButtonThemeData
  get floatingActionButtonTheme => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 6,
    focusElevation: 8,
    hoverElevation: 8,
    highlightElevation: 12,
    disabledElevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    sizeConstraints: BoxConstraints.tightFor(width: 56.w, height: 56.h),
    smallSizeConstraints: BoxConstraints.tightFor(width: 40.w, height: 40.h),
    largeSizeConstraints: BoxConstraints.tightFor(width: 96.w, height: 96.h),
    extendedPadding: EdgeInsets.symmetric(horizontal: 20.w),
  );

  // ============================================
  // FILLED BUTTON (Toggle/Segmented)
  // ============================================

  /// Filled button style for toggles
  static FilledButtonThemeData get filledButtonTheme => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.12),
      disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.38),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      minimumSize: Size(64.w, 48.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
  );
}

