import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/providers/premium_provider.dart';
import 'package:game_score/services/purchase_service.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppThemes.themeColor_1,
                    AppThemes.themeColor_1.withValues(alpha: 0.95),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF5F5F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header con botón de volver
                  _BackButton(),
                  const SizedBox(height: 20),

                  // Logo Premium con efecto shine
                  _PremiumLogo(),
                  const SizedBox(height: 24),

                  // Título
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'Coro Games PRO',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Desbloquea todo el potencial',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Features
                  _FeatureItem(
                    icon: FontAwesomeIcons.userGroup,
                    title: 'Jugadores ilimitados',
                    description: 'Sin límite de jugadores por partida',
                    delay: 400,
                  ),
                  _FeatureItem(
                    icon: FontAwesomeIcons.gamepad,
                    title: 'Partidas ilimitadas',
                    description: 'Crea todas las partidas que quieras',
                    delay: 500,
                  ),
                  _FeatureItem(
                    icon: FontAwesomeIcons.gamepad,
                    title: 'Partidas predefinidas',
                    description: 'Guarda configuraciones ilimitadas',
                    delay: 600,
                  ),
                  _FeatureItem(
                    icon: FontAwesomeIcons.clockRotateLeft,
                    title: 'Historial completo',
                    description: 'Accede a todo el historial de jugadas',
                    delay: 700,
                  ),
                  _FeatureItem(
                    icon: FontAwesomeIcons.ban,
                    title: 'Sin anuncios',
                    description: 'Disfruta sin interrupciones',
                    delay: 800,
                  ),

                  const SizedBox(height: 32),

                  // Botón de compra
                  Consumer<PremiumProvider>(
                    builder: (context, premiumProvider, child) {
                      if (premiumProvider.isPremium) {
                        return _AlreadyPremiumCard();
                      }
                      return _BuyButton(onTap: () => _buyPremium(context));
                    },
                  ),

                  const SizedBox(height: 14),

                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lock,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pago único • Sin suscripción',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _buyPremium(BuildContext context) async {
    final premiumProvider = context.read<PremiumProvider>();

    await premiumProvider.checkAndRestorePurchases();

    if (premiumProvider.isPremium) {
      Toast.show(
        type: ToastType.success,
        context: context,
        message: '¡Compra restaurada! Ya eres Premium.',
      );
      return;
    }

    final success = await PurchaseService.instance.buyPremium();
    if (!success) {
      Toast.show(
        type: ToastType.error,
        context: context,
        message: 'No se pudo completar la compra. Intenta de nuevo.',
      );
    }
  }
}

// Botón de volver
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.8),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  size: 18,
                  color: isDark ? Colors.white70 : AppThemes.colorCuarto,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Logo Premium con efecto shine
class _PremiumLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.asset(
            'assets/icon/icon-pro.png',
            width: 130,
            height: 130,
          ),
        ),
      ),
    );
  }
}

// Feature item
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.06),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono con gradiente azul
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemes.colorPrimero.withValues(alpha: 0.2),
                    AppThemes.colorTercero.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: FaIcon(icon, size: 20, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppThemes.colorCuarto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Check
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.check, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card "Ya eres Premium"
class _AlreadyPremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF66BB6A).withValues(alpha: 0.15),
              const Color(0xFF43A047).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF66BB6A).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43A047).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.crown, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '¡Ya eres Premium!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF81C784) : const Color(0xFF43A047),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón de compra
class _BuyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BuyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 900),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.colorTercero.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.crown, size: 18, color: Colors.white),
                    const SizedBox(width: 10),
                    const Text(
                      'Obtener PRO',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  PurchaseService.instance.premiumPrice,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
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
