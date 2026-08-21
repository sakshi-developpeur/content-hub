import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

/// Component Theme Configuration for OTT App
///
/// Includes themes for AppBar, Cards, Dialogs, BottomSheet, TabBar, and more.
class AppComponentTheme {
  AppComponentTheme._();

  // ============================================
  // APP BAR THEME
  // ============================================

  /// AppBar theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: AppColors.scaffoldBackground,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24.w),
    actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 24.w),
    titleTextStyle: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
    ),
    toolbarHeight: 56.h,
    toolbarTextStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
  );

  // ============================================
  // CARD THEME
  // ============================================

  /// Card theme
  static CardThemeData get cardTheme => CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    shadowColor: AppColors.shadow.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    margin: EdgeInsets.all(8.w),
  );

  // ============================================
  // DIALOG THEME
  // ============================================

  /// Dialog theme
  static DialogThemeData get dialogTheme => DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 24,
    shadowColor: AppColors.shadow.withValues(alpha: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    titleTextStyle: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    alignment: Alignment.center,
    actionsPadding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 20.h),
  );

  // ============================================
  // BOTTOM SHEET THEME
  // ============================================

  /// Bottom sheet theme
  static BottomSheetThemeData get bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: AppColors.shadow.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.outline,
    dragHandleSize: Size(40.w, 4.h),
    modalBackgroundColor: AppColors.surface,
    modalElevation: 8,
  );

  // ============================================
  // TAB BAR THEME
  // ============================================

  /// Tab bar theme
  static TabBarThemeData get tabBarTheme => TabBarThemeData(
    indicatorColor: AppColors.primary,
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    overlayColor: WidgetStateProperty.all(
      AppColors.primary.withValues(alpha: 0.1),
    ),
    labelStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelPadding: EdgeInsets.symmetric(horizontal: 20.w),
  );

  // ============================================
  // CHIP THEME
  // ============================================

  /// Chip theme
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    disabledColor: AppColors.surface.withValues(alpha: 0.38),
    selectedColor: AppColors.primary,
    secondarySelectedColor: AppColors.primaryContainer,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    labelStyle: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.onPrimary,
    ),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
      side: BorderSide(color: AppColors.outline, width: 1),
    ),
    side: BorderSide(color: AppColors.outline, width: 1),
    iconTheme: IconThemeData(color: AppColors.textSecondary, size: 18.w),
    checkmarkColor: AppColors.onPrimary,
    deleteIconColor: AppColors.textSecondary,
    showCheckmark: true,
  );

  // ============================================
  // BOTTOM NAVIGATION BAR THEME
  // ============================================

  /// Bottom navigation bar theme
  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        selectedIconTheme: IconThemeData(size: 24.w, color: AppColors.primary),
        unselectedIconTheme: IconThemeData(
          size: 24.w,
          color: AppColors.textSecondary,
        ),
      );

  // ============================================
  // NAVIGATION BAR THEME (Material 3)
  // ============================================

  /// Navigation bar theme (Material 3 style)
  static NavigationBarThemeData get navigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64.h,
        indicatorColor: AppColors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 24.w);
          }
          return IconThemeData(color: AppColors.textSecondary, size: 24.w);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          );
        }),
      );

  // ============================================
  // SNACK BAR THEME
  // ============================================

  /// Snack bar theme
  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.inverseSurface,
    contentTextStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.inverseOnSurface,
    ),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    showCloseIcon: false,
    closeIconColor: AppColors.inverseOnSurface,
    dismissDirection: DismissDirection.horizontal,
  );

  // ============================================
  // DIVIDER THEME
  // ============================================

  /// Divider theme
  static DividerThemeData get dividerTheme => DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
    indent: 0,
    endIndent: 0,
  );

  // ============================================
  // ICON THEME
  // ============================================

  /// Primary icon theme
  static IconThemeData get iconTheme =>
      IconThemeData(color: AppColors.textPrimary, size: 24.w, opacity: 1.0);

  /// Primary icon theme for actions
  static IconThemeData get primaryIconTheme =>
      IconThemeData(color: AppColors.primary, size: 24.w, opacity: 1.0);

  // ============================================
  // DRAWER THEME
  // ============================================

  /// Drawer theme
  static DrawerThemeData get drawerTheme => DrawerThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 16,
    shadowColor: AppColors.shadow.withValues(alpha: 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(16.r)),
    ),
  );

  // ============================================
  // LIST TILE THEME
  // ============================================

  /// List tile theme
  static ListTileThemeData get listTileTheme => ListTileThemeData(
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
    iconColor: AppColors.textSecondary,
    selectedColor: AppColors.primary,
    textColor: AppColors.textPrimary,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    minVerticalPadding: 8.h,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    style: ListTileStyle.list,
    dense: false,
    visualDensity: VisualDensity.standard,
    titleTextStyle: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );

  // ============================================
  // TOOLTIP THEME
  // ============================================

  /// Tooltip theme
  static TooltipThemeData get tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.inverseSurface,
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    waitDuration: const Duration(milliseconds: 500),
    showDuration: const Duration(milliseconds: 1500),
    preferBelow: true,
  );

  // ============================================
  // POPUP MENU THEME
  // ============================================

  /// Popup menu theme
  static PopupMenuThemeData get popupMenuTheme => PopupMenuThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: AppColors.shadow.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    iconColor: AppColors.textSecondary,
    iconSize: 20.w,
  );

  // ============================================
  // EXPANSION TILE THEME
  // ============================================

  /// Expansion tile theme
  static ExpansionTileThemeData get expansionTileTheme =>
      ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        collapsedTextColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      );

  // ============================================
  // BADGE THEME
  // ============================================

  /// Badge theme
  static BadgeThemeData get badgeTheme => BadgeThemeData(
    backgroundColor: AppColors.error,
    textColor: AppColors.onError,
    smallSize: 8.w,
    largeSize: 16.w,
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    alignment: AlignmentDirectional.topEnd,
    offset: Offset(-4.w, 4.h),
  );

  // ============================================
  // SCROLLBAR THEME
  // ============================================

  /// Scrollbar theme
  static ScrollbarThemeData get scrollbarTheme => ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.outline),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    radius: Radius.circular(4.r),
    thickness: WidgetStateProperty.all(4.w),
    thumbVisibility: WidgetStateProperty.all(false),
    trackVisibility: WidgetStateProperty.all(false),
    interactive: true,
    minThumbLength: 36.h,
  );
}

