import 'package:flutter/material.dart';

class ResponsiveApp {
  static MediaQueryData? _mediaQueryData;

  static MediaQueryData get mq {
    return _mediaQueryData!;
  }

  static Size get size {
    return _mediaQueryData!.size;
  }

  static void setMq(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }
}
