import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive Spacing
class Spacing {
  Spacing._();

  static SizedBox w(double width) => SizedBox(width: width.w);
  static SizedBox h(double height) => SizedBox(height: height.h);
}

/// Responsive Margin
class AppMargin {
  AppMargin._();

  static EdgeInsets all(double value) => EdgeInsets.all(value.w);
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value.w);
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value.h);
  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h.w, vertical: v.h);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: left.w,
    top: top.h,
    right: right.w,
    bottom: bottom.h,
  );
}

/// Responsive Padding
class AppPaddings {
  AppPaddings._();

  static EdgeInsets all(double value) => EdgeInsets.all(value.w);
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value.w);
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value.h);
  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h.w, vertical: v.h);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: left.w,
    top: top.h,
    right: right.w,
    bottom: bottom.h,
  );
}

/// Responsive Border Radius
class AppRadius {
  AppRadius._();

  static BorderRadius all(double value) => BorderRadius.circular(value.r);

  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft.r),
    topRight: Radius.circular(topRight.r),
    bottomLeft: Radius.circular(bottomLeft.r),
    bottomRight: Radius.circular(bottomRight.r),
  );
}

