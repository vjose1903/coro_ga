import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyLoading {
  MyLoading({Key? key});

  static show({String? message}) async {
    final isDark = Preferences.isDarkMode;

    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 60.0
      ..radius = 16.0
      ..backgroundColor = isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95)
      ..textColor = isDark ? Colors.white : AppThemes.colorCuarto
      ..textStyle = TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white70 : AppThemes.colorCuarto.withValues(alpha: 0.8),
      )
      ..indicatorColor = Colors.transparent
      ..maskColor = Colors.black.withValues(alpha: 0.6)
      ..userInteractions = false
      ..dismissOnTap = false
      ..boxShadow = [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        if (!isDark)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(-2, -2),
          ),
      ]
      ..contentPadding = const EdgeInsets.symmetric(horizontal: 28, vertical: 24);

    EasyLoading.show(
      maskType: EasyLoadingMaskType.custom,
      status: message ?? _getLoadingText(),
      indicator: _buildLoadingIndicator(isDark),
    );
  }

  static Widget _buildLoadingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemes.colorPrimero.withValues(alpha: 0.1),
            AppThemes.colorTercero.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: AppThemes.colorPrimero,
        size: 60,
      ),
    );
  }

  static showWithTimeout({String? message, int seconds = 3}) async {
    show(message: message);
    await Future.delayed(Duration(seconds: seconds));
    close();
  }

  static close() {
    EasyLoading.dismiss();
  }

  static String _getLoadingText() {
    final lang = Preferences.languageCode;
    return lang == 'en' ? 'Loading...' : 'Cargando...';
  }
}
