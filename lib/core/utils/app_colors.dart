import 'package:flutter/material.dart';

/// App Color Palette for OTT App
///
/// Usage: AppColors.primary, AppColors.scaffoldBackground, etc.
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS
  // ============================================

  /// Main primary color - used for buttons, CTAs, and primary actions
  static const Color primary = Color(0xFF543EE9);

  /// Lighter variant of primary
  static const Color primaryLight = Color(0xFF7C6BF0);

  /// Darker variant of primary
  static const Color primaryDark = Color(0xFF3D2CB8);

  /// Container color for primary elements
  static const Color primaryContainer = Color(0xFF2A1F7A);

  /// Text/icon color on primary backgrounds
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text/icon color on primary container
  static const Color onPrimaryContainer = Color(0xFFE8E4FF);

  // ============================================
  // SECONDARY COLORS
  // ============================================

  /// Secondary accent color
  static const Color secondary = Color(0xFF9B8DFF);

  /// Light secondary
  static const Color secondaryLight = Color(0xFFB8ADFF);

  /// Container for secondary elements
  static const Color secondaryContainer = Color(0xFF3D3566);

  /// Text/icon color on secondary
  static const Color onSecondary = Color(0xFF1A1040);

  /// Text/icon color on secondary container
  static const Color onSecondaryContainer = Color(0xFFE8E4FF);

  // ============================================
  // TERTIARY / ACCENT COLORS
  // ============================================

  /// Tertiary accent for highlights
  static const Color tertiary = Color(0xFFFF6B9D);

  /// Tertiary container
  static const Color tertiaryContainer = Color(0xFF5C2E42);

  /// Text/icon on tertiary
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ============================================
  // BACKGROUND COLORS
  // ============================================

  /// Main scaffold/app background color
  static const Color scaffoldBackground = Color(0xFF0C042E);

  /// Surface color for cards, sheets, dialogs
  static const Color surface = Color(0xFF1A1040);

  /// Variant surface (slightly different from surface)
  static const Color surfaceVariant = Color(0xFF241852);

  /// Elevated surface (cards with elevation)
  static const Color surfaceContainer = Color(0xFF1F1448);

  /// Highest elevation surface
  static const Color surfaceContainerHigh = Color(0xFF2A1D5C);

  /// Inverse surface for contrast elements
  static const Color inverseSurface = Color(0xFFE6E1E5);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text color (white for dark theme)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text color (slightly muted)
  static const Color textSecondary = Color(0xFFB8B2C7);

  /// Hint/placeholder text color
  static const Color textHint = Color(0xFF7A7490);

  /// Disabled text color
  static const Color textDisabled = Color(0xFF4D4766);

  /// Text on surface
  static const Color onSurface = Color(0xFFFFFFFF);

  /// Text on surface variant
  static const Color onSurfaceVariant = Color(0xFFCAC4D0);

  /// Inverse text (dark text for light backgrounds)
  static const Color inverseOnSurface = Color(0xFF1C1B1F);

  // ============================================
  // BORDER & DIVIDER COLORS
  // ============================================

  /// Outline/border color
  static const Color outline = Color(0xFF3D3566);

  /// Subtle outline variant
  static const Color outlineVariant = Color(0xFF2A2352);

  /// Divider color
  static const Color divider = Color(0xFF2A2352);

  // ============================================
  // STATUS / ACCENT COLORS
  // ============================================

  /// Success color
  static const Color success = Color(0xFF4CAF50);

  /// Success container
  static const Color successContainer = Color(0xFF1B4D1E);

  /// Warning color
  static const Color warning = Color(0xFFFF9800);

  /// Warning container
  static const Color warningContainer = Color(0xFF4D3000);

  /// Error color
  static const Color error = Color(0xFFF44336);

  /// Error container
  static const Color errorContainer = Color(0xFF4D1414);

  /// On error
  static const Color onError = Color(0xFFFFFFFF);

  /// On error container
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  /// Info color
  static const Color info = Color(0xFF2196F3);

  /// Info container
  static const Color infoContainer = Color(0xFF0D3A5C);

  // ============================================
  // GRADIENT COLORS
  // ============================================

  /// Primary gradient start
  static const Color gradientStart = Color(0xFF543EE9);

  /// Primary gradient end
  static const Color gradientEnd = Color(0xFF9B8DFF);

  /// Primary button gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card gradient overlay
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x00000000), Color(0xCC0C042E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================
  // SHIMMER COLORS
  // ============================================

  /// Shimmer base color
  static const Color shimmerBase = Color(0xFF1A1040);

  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFF2A1D5C);

  // ============================================
  // SHADOW COLORS
  // ============================================

  /// Shadow color
  static const Color shadow = Color(0xFF000000);

  /// Scrim/overlay color
  static const Color scrim = Color(0xFF000000);
}

