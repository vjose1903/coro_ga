import 'package:flutter/material.dart';

class MyMediaQuery {
  static late MediaQueryData _mediaQueryData;

  static MediaQueryData get mq => _mediaQueryData;

  static void setMq(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }
}
