import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../l10n/app_localizations.dart';
import '../services/version_service.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/helpers.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

class ForceUpdateModal extends StatelessWidget {
  const ForceUpdateModal({super.key});

  static Future<void> showIfNeeded(BuildContext context, {bool forceShow = false}) async {
    // En desarrollo solo mostrar si se pasa forceShow
    if (kDebugMode && !forceShow) return;

    final updateAvailable = await VersionService.instance.checkForUpdate();

    if ((updateAvailable || forceShow) && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        builder: (context) => const ForceUpdateModal(),
      );
    }
  }

  Future<void> _openStore() async {
    final url = VersionService.instance.getStoreUrl();
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

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
                // Icono de la app
                ZoomIn(
                  delay: const Duration(milliseconds: 200),
                  child: Image.asset(
                    Preferences.isPremium ? 'assets/icon/iconCircular-pro.png' : 'assets/icon/iconCircular.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),

                // Título
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return TextScale(
                        l10n.newVersionTitle,
                        textAlign: TextAlign.center,
                        size: 22,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Subtítulo
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return TextScale(
                        l10n.newVersionAvailable,
                        textAlign: TextAlign.center,
                        size: 14,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de actualizar
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppThemes.colorCuarto,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconScale(
                            Icons.download_rounded,
                            size: 22,
                            color: AppThemes.colorCuarto,
                          ),
                          const SizedBox(width: 10),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return TextScale(
                                l10n.updateNow,
                                size: 16,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: AppThemes.colorCuarto,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
