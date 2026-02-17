import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveApp {
  static const double _baseWidth = 390;
  static const double _baseHeight = 844;

  static MediaQueryData? _mediaQueryData;

  static MediaQueryData get mq => _mediaQueryData!;
  static Size get size => _mediaQueryData!.size;
  static double get width => size.width;
  static double get height => size.height;
  static double get shortestSide => size.shortestSide;
  static Orientation get orientation => mq.orientation;

  static bool get isLandscape => orientation == Orientation.landscape;
  static bool get isPortrait => orientation == Orientation.portrait;
  static double get aspectRatio => width / height;

  static bool isLandscapeFor(BoxConstraints constraints) => constraints.maxWidth > constraints.maxHeight;

  static const double _wideLayoutMinWidth = 600;
  static bool get isWideLayout => shortestSide >= _wideLayoutMinWidth;
  // Use landscape layout for landscape or wide devices.
  static bool get useLandscapeLayout => isLandscape || isWideLayout;

  static void setMq(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }

  static double get _scaleFactor => min(width / _baseWidth, height / _baseHeight);

  static double scaleWidth(double value) => value * width / _baseWidth;
  static double scaleHeight(double value) => value * height / _baseHeight;
  static double scaleText(double value) => value * _scaleFactor;

  static bool get isSmallWidth => width <= 360;
  static bool get isSmallHeight => height <= 700;

  static double widthFactor(double factor) => width * factor;

  static EdgeInsets all(double value) => EdgeInsets.all(scaleWidth(value));

  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) => EdgeInsets.symmetric(horizontal: scaleWidth(horizontal), vertical: scaleHeight(vertical));

  static EdgeInsets only({double left = 0, double top = 0, double right = 0, double bottom = 0}) => EdgeInsets.only(
        left: scaleWidth(left),
        top: scaleHeight(top),
        right: scaleWidth(right),
        bottom: scaleHeight(bottom),
      );

  static BorderRadius borderRadius(double value) => BorderRadius.circular(scaleWidth(value));
}
