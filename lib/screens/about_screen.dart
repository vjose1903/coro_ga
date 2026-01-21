import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  // Mismo gradiente del Layout principal
  static const _backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      transform: GradientRotation(-0.4),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.4, 1.0],
      colors: [
        Color(0xFF3D47D9),
        Color(0xFF1A237E),
        Color(0xFF0D1442),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return ScreenTracker(
      screenName: 'AboutScreen',
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo con gradiente
            Container(decoration: _backgroundDecoration),
            // Decoración de círculos sutiles
            const _BackgroundCircles(),
            // AppBar custom
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CustomIconButtom(
                      iconSize: ResponsiveApp.isSmallHeight ? 18 : 22,
                      iconColor: Colors.white,
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.aboutTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveApp.scaleText(20),
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Body con el contenido
            Column(
              children: [
                SizedBox(height: topPadding + 65),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(50)),
                      color: AppThemes.themeColor_1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(50)),
                      child: _AboutContent(l10n: l10n),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundCircles extends StatelessWidget {
  const _BackgroundCircles();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _CirclesPainter()),
      ),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 60, paint);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      40,
      paint..color = Colors.white.withValues(alpha: 0.02),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AboutContent extends StatelessWidget {
  final AppLocalizations l10n;
  const _AboutContent({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo con sombra
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon/icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // App Name
          Text(
            'Coro Games',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(28),
              fontWeight: FontWeight.bold,
              color: Preferences.isDarkMode ? Colors.white : AppThemes.colorCuarto,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData ? 'v${snapshot.data!.version}' : '';
              return Text(
                version,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: ResponsiveApp.scaleText(14),
                  color: Colors.grey[500],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // About Section
          _SectionCard(
            icon: FontAwesomeIcons.gamepad,
            title: l10n.aboutAppTitle,
            child: Text(
              l10n.aboutAppDescription,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(14),
                height: 1.6,
                color: Preferences.isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Privacy Section
          _SectionCard(
            icon: FontAwesomeIcons.shieldHalved,
            title: l10n.privacyPolicyTitle,
            child: Column(
              children: [
                Text(
                  l10n.privacyPolicyDescription,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: ResponsiveApp.scaleText(14),
                    height: 1.6,
                    color: Preferences.isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _PrivacyPolicyButton(label: l10n.viewFullPrivacyPolicy),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Footer
          Text(
            '© 2024-${DateTime.now().year} Coro Games',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(12),
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PrivacyPolicyButton extends StatelessWidget {
  final String label;
  const _PrivacyPolicyButton({required this.label});

  void _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://coro-games.netlify.app/');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launchPrivacyPolicy,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppThemes.colorTercero.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.arrowUpRightFromSquare,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: ResponsiveApp.scaleText(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemes.themeColor_2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppThemes.colorPrimero.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FaIcon(
              icon,
              size: 22,
              color: AppThemes.colorPrimero,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(18),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppThemes.colorCuarto,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
