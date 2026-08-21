import 'package:flutter/material.dart';
import 'package:estoriz/core/utils/app_colors.dart';

enum DeviceType { mobile, tablet, desktop }

class FontConfig {
  FontConfig._();
  // --- BODY MEDIUM (Your specific request) ---
  static const double bodyMediumMobile = 14.0;
  static const double bodyMediumTablet = 16.0;
  static const double bodyMediumDesktop = 18.0;

  // --- BODY SMALL ---
  static const double bodySmallMobile = 12.0;
  static const double bodySmallTablet = 14.0;
  static const double bodySmallDesktop = 16.0;

  // --- BODY LARGE ---
  static const double bodyLargeMobile = 16.0;
  static const double bodyLargeTablet = 18.0;
  static const double bodyLargeDesktop = 20.0;

  // --- TITLES ---
  static const double titleMobile = 22.0;
  static const double titleTablet = 26.0;
  static const double titleDesktop = 30.0;
}

class ScreenHelper {
  ScreenHelper._();
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width >= 1100) return DeviceType.desktop;
    if (width >= 650) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;

  // These internal variables store the size for each device type
  final double _mobileSize;
  final double _tabletSize;
  final double _desktopSize;

  // Private Constructor
  const ResponsiveText._internal({
    required this.text,
    required double mobileSize,
    required double tabletSize,
    required double desktopSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
  }) : _mobileSize = mobileSize,
       _tabletSize = tabletSize,
       _desktopSize = desktopSize;

  // --- 1. BODY SMALL (12 -> 14 -> 16) ---
  factory ResponsiveText.bodySmall(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return ResponsiveText._internal(
      text: text,
      mobileSize: FontConfig.bodySmallMobile,
      tabletSize: FontConfig.bodySmallTablet,
      desktopSize: FontConfig.bodySmallDesktop,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
    );
  }

  // --- 2. BODY MEDIUM (14 -> 16 -> 18) ---
  factory ResponsiveText.bodyMedium(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return ResponsiveText._internal(
      text: text,
      mobileSize: FontConfig.bodyMediumMobile,
      tabletSize: FontConfig.bodyMediumTablet,
      desktopSize: FontConfig.bodyMediumDesktop,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
    );
  }

  // --- 3. BODY LARGE (16 -> 18 -> 20) ---
  factory ResponsiveText.bodyLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return ResponsiveText._internal(
      text: text,
      mobileSize: FontConfig.bodyLargeMobile,
      tabletSize: FontConfig.bodyLargeTablet,
      desktopSize: FontConfig.bodyLargeDesktop,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
    );
  }

  factory ResponsiveText.title(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return ResponsiveText._internal(
      text: text,
      mobileSize: FontConfig.titleMobile,
      tabletSize: FontConfig.titleTablet,
      desktopSize: FontConfig.titleDesktop,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    double fontSize;

    // logic to pick the correct size
    DeviceType deviceType = ScreenHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.desktop:
        fontSize = _desktopSize;
      case DeviceType.tablet:
        fontSize = _tabletSize;
      case DeviceType.mobile:
        fontSize = _mobileSize;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? AppColors.textPrimary,
        fontWeight: fontWeight,
        fontFamily: 'Montserrat',
      ),
    );
  }
}


//###############################  how to use ###############################
// Inside your View
// Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     // On Mobile: Size 22 | Tablet: 26 | Desktop: 30
//     ResponsiveText.title("Dashboard"), 

//     SizedBox(height: 10),

//     // On Mobile: Size 14 | Tablet: 16 | Desktop: 18
//     ResponsiveText.bodyMedium(
//        "Welcome back, user! Here is your summary.",
//        color: Colors.grey[700],
//     ),
//   ],
// )
