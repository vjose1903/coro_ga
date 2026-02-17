import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import 'text_scale.dart';

class NoInternetModal extends StatelessWidget {
  const NoInternetModal({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemes.colorQuinto,
                  AppThemes.colorCuarto,
                  AppThemes.colorTercero,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.colorTercero.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZoomIn(
                  delay: const Duration(milliseconds: 200),
                  child: Image.asset(
                    Preferences.isPremium
                        ? 'assets/icon/iconCircular-pro.png'
                        : 'assets/icon/iconCircular.png',
                    width: 96,
                    height: 96,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: TextScale(
                    AppLocalizations.of(context)!.noInternetTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveApp.scaleText(20),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: TextScale(
                    AppLocalizations.of(context)!.noInternetMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveApp.scaleText(14),
                      fontFamily: 'Poppins',
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextScale(
                        AppLocalizations.of(context)!.noInternetWaiting,
                        style: TextStyle(
                          fontSize: ResponsiveApp.scaleText(13),
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
