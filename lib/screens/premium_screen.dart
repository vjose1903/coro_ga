import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/premium_provider.dart';
import '../services/purchase_service.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

enum _ProcessingAction { none, buy, restore }

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isProcessing = false;
  _ProcessingAction _activeAction = _ProcessingAction.none;

  Future<void> _runWithSpinner(_ProcessingAction action, Future<void> Function() work) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _activeAction = action;
    });
    try {
      await work();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _activeAction = _ProcessingAction.none;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    return ScreenTracker(
      screenName: 'PremiumScreen',
      child: Scaffold(
        body: DecoratedBox(
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ResponsiveLayoutBuilder(
                builder: (context, constraints, info) {
                  final useLandscapeLayout = info.useLandscapeLayout;
                  final isWide = info.isWide;

                  final headerRow = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BackButton(isWide: isWide, useLandscapeLayout: useLandscapeLayout),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isProcessing ? null : () => _restorePremium(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_activeAction == _ProcessingAction.restore) ...[
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.25,
                                      valueColor: AlwaysStoppedAnimation(
                                        isDark ? Colors.white : AppThemes.colorPrimero,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                TextScale(
                                  AppLocalizations.of(context)!.restorePurchases,
                                  size: 14,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? (_isProcessing ? Colors.white38 : Colors.white70) : (_isProcessing ? AppThemes.colorPrimero : AppThemes.colorTercero),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                  final title = FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: TextScale(
                        AppLocalizations.of(context)!.coroGamesPro,
                        size: 26,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );

                  final subtitle = FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: TextScale(
                      AppLocalizations.of(context)!.unlockFullPotential,
                      size: 15,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  );

                  final features = [
                    _FeatureItem(
                      icon: FontAwesomeIcons.userGroup,
                      title: AppLocalizations.of(context)!.unlimitedPlayers,
                      description: AppLocalizations.of(context)!.unlimitedPlayersDesc,
                      delay: 400,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                    ),
                    _FeatureItem(
                      icon: FontAwesomeIcons.gamepad,
                      title: AppLocalizations.of(context)!.unlimitedGames,
                      description: AppLocalizations.of(context)!.unlimitedGamesDesc,
                      delay: 500,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                    ),
                    _FeatureItem(
                      icon: FontAwesomeIcons.gamepad,
                      title: AppLocalizations.of(context)!.predefinedGamesFeature,
                      description: AppLocalizations.of(context)!.predefinedGamesDesc,
                      delay: 600,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                    ),
                    _FeatureItem(
                      icon: FontAwesomeIcons.clockRotateLeft,
                      title: AppLocalizations.of(context)!.fullHistory,
                      description: AppLocalizations.of(context)!.fullHistoryDesc,
                      delay: 700,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                    ),
                    _FeatureItem(
                      icon: FontAwesomeIcons.ban,
                      title: AppLocalizations.of(context)!.noAds,
                      description: AppLocalizations.of(context)!.noAdsDesc,
                      delay: 800,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                    ),
                  ];

                  final buySection = Consumer<PremiumProvider>(
                    builder: (context, premiumProvider, child) {
                      if (premiumProvider.isPremium) {
                        return _AlreadyPremiumCard();
                      }
                      return _BuyButton(
                        enabled: !_isProcessing,
                        showSpinner: _activeAction == _ProcessingAction.buy,
                        useLandscapeLayout: useLandscapeLayout,
                        isWide: isWide,
                        onTap: () => _buyPremium(context),
                      );
                    },
                  );

                  final footnote = FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconScale(
                          FontAwesomeIcons.lock,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        TextScale(
                          AppLocalizations.of(context)!.oneTimePayment,
                          size: 12,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white38 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );

                  if (!useLandscapeLayout) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          headerRow,
                          const SizedBox(height: 20),
                          const _PremiumLogo(),
                          const SizedBox(height: 24),
                          title,
                          const SizedBox(height: 8),
                          subtitle,
                          const SizedBox(height: 32),
                          ...features,
                          const SizedBox(height: 32),
                          buySection,
                          const SizedBox(height: 14),
                          footnote,
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: constraints.maxHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              headerRow,
                              const SizedBox(height: 12),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, leftConstraints) {
                                    final availableHeight = leftConstraints.maxHeight;
                                    final logoSize = (availableHeight * 0.46).clamp(72.0, 130.0);
                                    final titleSize = (availableHeight * 0.11).clamp(20.0, 28.0);
                                    final subtitleSize = (availableHeight * 0.06).clamp(12.0, 15.0);
                                    final logoGap = (availableHeight * 0.08).clamp(10.0, 24.0);
                                    final subtitleGap = (availableHeight * 0.03).clamp(4.0, 8.0);

                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _PremiumLogo(size: logoSize),
                                          SizedBox(height: logoGap),
                                          FadeInUp(
                                            delay: const Duration(milliseconds: 200),
                                            child: ShaderMask(
                                              shaderCallback: (bounds) => const LinearGradient(
                                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ).createShader(bounds),
                                              child: TextScale(
                                                AppLocalizations.of(context)!.coroGamesPro,
                                                size: titleSize,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: subtitleGap),
                                          FadeInUp(
                                            delay: const Duration(milliseconds: 300),
                                            child: TextScale(
                                              AppLocalizations.of(context)!.unlockFullPotential,
                                              size: subtitleSize,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: isDark ? Colors.white54 : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              buySection,
                              const SizedBox(height: 14),
                              footnote,
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ...features,
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _buyPremium(BuildContext context) async {
    await _runWithSpinner(_ProcessingAction.buy, () async {
      final success = await PurchaseService.instance.buyPremium();
      if (!context.mounted) return;
      if (!success) {
        Toast.show(
          type: ToastType.error,
          context: context,
          message: AppLocalizations.of(context)!.purchaseFailed,
        );
      }
    });
  }

  Future<void> _restorePremium(BuildContext context) async {
    await _runWithSpinner(_ProcessingAction.restore, () async {
      final provider = context.read<PremiumProvider>();
      await provider.checkAndRestorePurchases();
      if (!context.mounted) return;

      final isPremium = provider.isPremium;
      Toast.show(
        type: isPremium ? ToastType.success : ToastType.error,
        context: context,
        message: isPremium ? AppLocalizations.of(context)!.purchaseRestored : AppLocalizations.of(context)!.restoreFailed,
      );
    });
  }
}

// Botón de volver
class _BackButton extends StatelessWidget {
  const _BackButton({required this.useLandscapeLayout, required this.isWide});

  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final iconSize = useLandscapeLayout ? (isWide ? 16.0 : 13.0) : 18.0;

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
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.8),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: IconScale(
                  FontAwesomeIcons.arrowLeft,
                  size: iconSize,
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
  const _PremiumLogo({this.size = 130});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final framePadding = (size * 0.046).clamp(4.0, 6.0);
    final outerRadius = (size * 0.246).clamp(20.0, 32.0);
    final innerRadius = (size * 0.2).clamp(16.0, 26.0);

    return FadeInDown(
      child: Container(
        padding: EdgeInsets.all(framePadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
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
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerRadius),
          child: Image.asset(
            'assets/icon/icon-pro.png',
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}

// Feature item
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
    required this.useLandscapeLayout,
    required this.isWide,
  });
  final IconData icon;
  final String title;
  final String description;
  final int delay;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.06),
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
                child: IconScale(
                  icon,
                  size: useLandscapeLayout ? (isWide ? 15 : 13) : 20,
                  color: AppThemes.colorPrimero,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextScale(
                    title,
                    size: 15,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppThemes.colorCuarto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextScale(
                    description,
                    size: 12,
                    style: TextStyle(
                      fontFamily: 'Poppins',
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
                child: IconScale(FontAwesomeIcons.check, size: 12, color: Colors.white),
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
                child: IconScale(FontAwesomeIcons.crown, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            TextScale(
              AppLocalizations.of(context)!.alreadyPremium,
              size: 18,
              style: TextStyle(
                fontFamily: 'Poppins',
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
  const _BuyButton({
    required this.onTap,
    this.enabled = true,
    this.showSpinner = false,
    this.useLandscapeLayout = false,
    this.isWide = false,
  });
  final VoidCallback onTap;
  final bool enabled;
  final bool showSpinner;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 900),
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: useLandscapeLayout ? 8 : 12),
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
                      if (showSpinner) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.25,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      IconScale(FontAwesomeIcons.crown, size: useLandscapeLayout ? (isWide ? 17 : 13) : 18, color: Colors.white),
                      const SizedBox(width: 10),
                      TextScale(
                        AppLocalizations.of(context)!.getPro,
                        size: 20,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextScale(
                    PurchaseService.instance.premiumPrice,
                    size: 14,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
