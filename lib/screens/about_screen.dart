import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../widgets/widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final PanelController panelController;

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenTracker(
      screenName: 'AboutScreen',
      child: Scaffold(
        body: Layout(
          panelController: panelController,
          appBarTitle: l10n.aboutTitle,
          appBarLeading: CustomIconButtom(
            iconSize: ResponsiveApp.isSmallHeight ? 18 : 22,
            iconColor: Colors.white,
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          bodyContent: _AboutContent(l10n: l10n),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, constraints, info) {
        final useLandscapeLayout = info.useLandscapeLayout;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: useLandscapeLayout
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Logo con sombra
                      DecoratedBox(
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
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
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
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(height: 20),
                // Logo con sombra
                DecoratedBox(
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
      },
    );
  }
}

class _PrivacyPolicyButton extends StatelessWidget {
  const _PrivacyPolicyButton({required this.label});
  final String label;

  void _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://coro-games.netlify.app/');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;

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
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
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
