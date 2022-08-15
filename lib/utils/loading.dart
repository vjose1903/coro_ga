import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyLoading {
  MyLoading({Key? key});

  static show() async {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = Colors.black.withOpacity(0.5)
      ..textColor = Colors.white
      ..indicatorColor = Colors.transparent
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;

    EasyLoading.show(
        maskType: EasyLoadingMaskType.custom,
        status: 'Cargando...',
        indicator: LoadingAnimationWidget.staggeredDotsWave(color: AppThemes.colorSegundo, size: 150));
    await Future.delayed(const Duration(seconds: 3));
    close();
  }

  static close() {
    EasyLoading.dismiss();
  }
}
