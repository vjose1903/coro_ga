import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/services/version_service.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateModal extends StatelessWidget {
  const ForceUpdateModal({Key? key}) : super(key: key);

  static Future<void> showIfNeeded(BuildContext context, {bool forceShow = false}) async {
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
    final isDark = Preferences.isDarkMode;
    
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppThemes.themeColor_2 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                // Sombra principal
                BoxShadow(
                  color: AppThemes.colorTercero.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                // Sombra neumórfica oscura
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(8, 8),
                ),
                // Sombra neumórfica clara
                if (!isDark)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 20,
                    offset: const Offset(-8, -8),
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de la app con efecto
                ZoomIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppThemes.colorPrimero.withValues(alpha: 0.3),
                          AppThemes.colorTercero.withValues(alpha: 0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemes.colorTercero.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppThemes.themeColor_2 : Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          Preferences.isPremium 
                              ? 'assets/icon/iconCircular-pro.png' 
                              : 'assets/icon/iconCircular.png',
                          width: 90,
                          height: 90,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Título
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child:  Text(
                      '¡Nueva versión disponible!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: AppThemes.colorPrimero,
                        letterSpacing: 0.3,
                      ),
                    ),
                  
                ),
                const SizedBox(height: 12),
                
                // Subtítulo
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'Hay una nueva versión de Coro Games disponible. Para poder continuar usando la aplicación, actualiza ahora.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.7) 
                          : Colors.black.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                
                // Botón de actualizar
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _UpdateButton(onPressed: _openStore),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const _UpdateButton({required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppThemes.colorTercero.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.download,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Actualizar ahora',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

