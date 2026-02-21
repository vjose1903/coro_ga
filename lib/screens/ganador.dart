// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class GanadorScreen extends StatefulWidget {
  const GanadorScreen({super.key});

  @override
  State<GanadorScreen> createState() => _GanadorScreenState();
}

class _GanadorScreenState extends State<GanadorScreen> {
  Future<PartidaFinalizada?>? _partidaFinalizadaFuture;
  PartidaFinalizada? _partidaFinalizada;
  int? _partidaFinalizadaId;
  Map? _routeArgs;
  bool _playIntroAnimations = true;
  bool _introAnimationMarkQueued = false;
  bool _isProcessingRematch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_partidaFinalizadaFuture != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _routeArgs = args;
      final rawId = args['partidaFinalizadaId'];
      if (rawId is int) _partidaFinalizadaId = rawId;
      if (rawId is String) _partidaFinalizadaId = int.tryParse(rawId);
    }

    if (_partidaFinalizadaId != null) {
      _partidaFinalizadaFuture = PartidaFinalizada.findById(_partidaFinalizadaId!);
    } else {
      _partidaFinalizadaFuture = Future.value();
    }
  }

  void _markIntroAnimationsAsPlayed() {
    if (_introAnimationMarkQueued || !_playIntroAnimations) return;
    _introAnimationMarkQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _playIntroAnimations = false;
      });
    });
  }

  void _goHomeAndResetStack() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _markIntroAnimationsAsPlayed();

    final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();
    googleAdsProvider.loadInterstitialAd();
    if (!premiumProvider.isPremium) {
      googleAdsProvider.loadRewardedAd(RewardedAdLocation.revancha);
    }

    final Color ganadorColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF06187E);
    final Color partidaColor = Preferences.isDarkMode ? AppThemes.colorSegundo : Colors.grey[700]!;

    final boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.3, 1],
        colors: [AppThemes.themeColor_1, const Color(0xFF08134F)],
      ),
    );

    return ScreenTracker(
      screenName: 'GanadorScreen',
      child: FutureBuilder<PartidaFinalizada?>(
        future: _partidaFinalizadaFuture,
        builder: (context, snapshot) {
          _partidaFinalizada = snapshot.data;

          final fallbackPartida = _routeArgs?['partida']?.toString() ?? AppLocalizations.of(context)!.noName;
          final fallbackJugador = _routeArgs?['jugador']?.toString() ?? Estado.empate;
          final String partida = _partidaFinalizada?.nombre ?? fallbackPartida;
          final String jugador = _partidaFinalizada?.ganador ?? _partidaFinalizada?.getGanadorFromJugadores() ?? fallbackJugador;

          return Scaffold(
            body: Stack(
              children: [
                Container(decoration: boxDecoration),
                SafeArea(
                  child: ResponsiveLayoutBuilder(
                    builder: (context, constraints, info) {
                      final maxH = constraints.maxHeight;
                      final maxW = constraints.maxWidth;
                      final isCompactHeight = maxH < 700;
                      final isNarrow = maxW < 360;
                      final useLandscapeLayout = info.useLandscapeLayout;
                      final isWide = info.isWide;

                      final closeTop = isCompactHeight ? 12.0 : 20.0;
                      final closeRight = isNarrow ? 12.0 : 20.0;
                      final headerTop = isCompactHeight ? 28.0 : 40.0;
                      final trophyHeight = (maxH * (isCompactHeight ? 0.32 : 0.38)).clamp(160.0, 320.0);
                      final titleSize = (ResponsiveApp.scaleText(30) * (isNarrow ? 0.9 : 1.0)).clamp(22.0, 34.0);
                      final subtitleSize = (ResponsiveApp.scaleText(20) * (isNarrow ? 0.9 : 1.0)).clamp(16.0, 24.0);
                      final nameSize = (ResponsiveApp.scaleText(30) * (isNarrow ? 0.9 : 1.0)).clamp(22.0, 34.0);
                      final rematchSize = (ResponsiveApp.scaleText(15) * (isNarrow ? 0.95 : 1.0)).clamp(13.0, 18.0);
                      final watchAdSize = (ResponsiveApp.scaleText(10) * (isNarrow ? 0.95 : 1.0)).clamp(9.0, 12.0);
                      final landscapeTitleSize = (titleSize * 1.18).clamp(24.0, 42.0);
                      final landscapeSubtitleSize = (subtitleSize * 1.15).clamp(17.0, 30.0);
                      final landscapeNameSize = (nameSize * 1.2).clamp(24.0, 44.0);
                      final landscapeRematchSize = (rematchSize * 1.5).clamp(14.0, 26.0);
                      final landscapeWatchAdSize = (watchAdSize * 1.3).clamp(10.0, 18.0);

                      final closeButton = Positioned(
                        top: closeTop,
                        right: closeRight,
                        child: WidgetAnimator(
                          incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingSlideInFromRight(delay: const Duration(seconds: 2, milliseconds: 500), duration: const Duration(seconds: 1)) : WidgetTransitionEffects(),
                          child: CustomIconButtom(
                              iconSize: useLandscapeLayout ? (isWide ? 40 : 30) : 40,
                              iconColor: ganadorColor,
                              icon: Icons.close,
                              onTap: () {
                                if (Preferences.isPremium) {
                                  _goHomeAndResetStack();
                                } else {
                                  googleAdsProvider.showInterstitialAd(onCloseFunction: () {
                                    if (!context.mounted) return;
                                    _goHomeAndResetStack();
                                    googleAdsProvider.loadInterstitialAd();
                                  });
                                }
                              }),
                        ),
                      );

                      if (useLandscapeLayout) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: isCompactHeight ? 20 : 30),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: maxH),
                            child: Stack(
                              children: [
                                closeButton,
                                Padding(
                                  padding: EdgeInsets.only(top: headerTop, left: 24, right: 24),
                                  child: SizedBox(
                                    height: maxH - headerTop,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 11,
                                          child: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 440),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextAnimator(
                                                    AppLocalizations.of(context)!.winner,
                                                    initialDelay: _playIntroAnimations ? const Duration(seconds: 1) : Duration.zero,
                                                    incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingOffsetThenScaleAndStep(duration: const Duration(milliseconds: 800)) : WidgetTransitionEffects(),
                                                    style: TextStyle(
                                                      color: ganadorColor,
                                                      fontFamily: 'Poppins',
                                                      fontSize: landscapeTitleSize,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextAnimator(
                                                    partida,
                                                    initialDelay: _playIntroAnimations ? const Duration(seconds: 1, milliseconds: 800) : Duration.zero,
                                                    incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingScaleDown(duration: const Duration(seconds: 1)) : WidgetTransitionEffects(),
                                                    style: TextStyle(
                                                      color: partidaColor,
                                                      fontFamily: 'Poppins',
                                                      fontSize: landscapeSubtitleSize,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  TextAnimator(
                                                    jugador,
                                                    spaceDelay: const Duration(),
                                                    characterDelay: _playIntroAnimations ? const Duration(milliseconds: 180) : Duration.zero,
                                                    incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingScaleUp() : WidgetTransitionEffects(),
                                                    atRestEffect: _playIntroAnimations ? WidgetRestingEffects.pulse(effectStrength: 0.8) : null,
                                                    initialDelay: _playIntroAnimations ? const Duration(seconds: 2) : Duration.zero,
                                                    style: TextStyle(
                                                      color: ganadorColor,
                                                      fontFamily: 'Poppins',
                                                      fontSize: landscapeNameSize,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 2.5,
                                                    ),
                                                  ),
                                                  SizedBox(height: isCompactHeight ? 18 : 24),
                                                  SizedBox(
                                                    width: 280,
                                                    child: WidgetAnimator(
                                                      incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.outgoingScaleUp(delay: const Duration(seconds: 2), duration: const Duration(seconds: 1)) : WidgetTransitionEffects(),
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green[400])),
                                                        onPressed: _isProcessingRematch ? null : () => revanchaFunction(),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            TextScale(
                                                              AppLocalizations.of(context)!.rematch,
                                                              size: landscapeRematchSize,
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins',
                                                                fontWeight: FontWeight.bold,
                                                                letterSpacing: 2,
                                                                color: Colors.green[900],
                                                              ),
                                                            ),
                                                            if (!premiumProvider.isPremium)
                                                              TextScale(
                                                                AppLocalizations.of(context)!.watchAd,
                                                                size: landscapeWatchAdSize,
                                                                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.normal, color: Colors.green[900]),
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
                                        const SizedBox(width: 24),
                                        Expanded(
                                          flex: 9,
                                          child: Center(
                                            child: SizedBox(
                                              height: (trophyHeight * 1.05).clamp(180.0, 360.0),
                                              child: Bounce(
                                                delay: _playIntroAnimations ? const Duration(seconds: 1) : Duration.zero,
                                                infinite: _playIntroAnimations,
                                                animate: _playIntroAnimations,
                                                child: const LottieAnimation(animationJson: 'assets/animations/trophy.json'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: isCompactHeight ? 20 : 40),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: maxH),
                          child: Stack(
                            children: [
                              closeButton,
                              Padding(
                                padding: EdgeInsets.only(top: headerTop),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      TextAnimator(AppLocalizations.of(context)!.winner,
                                          initialDelay: _playIntroAnimations ? const Duration(seconds: 1) : Duration.zero,
                                          incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingOffsetThenScaleAndStep(duration: const Duration(milliseconds: 800)) : WidgetTransitionEffects(),
                                          style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: titleSize, fontWeight: FontWeight.bold, letterSpacing: 3)),
                                      TextAnimator(partida,
                                          initialDelay: _playIntroAnimations ? const Duration(seconds: 1, milliseconds: 800) : Duration.zero,
                                          incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingScaleDown(duration: const Duration(seconds: 1)) : WidgetTransitionEffects(),
                                          style: TextStyle(color: partidaColor, fontFamily: 'Poppins', fontSize: subtitleSize)),
                                      SizedBox(height: isCompactHeight ? 12 : 20),
                                      SizedBox(
                                        height: trophyHeight,
                                        child: Bounce(
                                          delay: _playIntroAnimations ? const Duration(seconds: 1) : Duration.zero,
                                          infinite: _playIntroAnimations,
                                          animate: _playIntroAnimations,
                                          child: const LottieAnimation(animationJson: 'assets/animations/trophy.json'),
                                        ),
                                      ),
                                      SizedBox(height: isCompactHeight ? 8 : 10),
                                      TextAnimator(jugador,
                                          spaceDelay: const Duration(),
                                          characterDelay: _playIntroAnimations ? const Duration(milliseconds: 180) : Duration.zero,
                                          incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.incomingScaleUp() : WidgetTransitionEffects(),
                                          atRestEffect: _playIntroAnimations ? WidgetRestingEffects.pulse(effectStrength: 0.8) : null,
                                          initialDelay: _playIntroAnimations ? const Duration(seconds: 2) : Duration.zero,
                                          style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: nameSize, fontWeight: FontWeight.bold, letterSpacing: 3)),
                                      SizedBox(height: isCompactHeight ? 24 : 40),
                                      WidgetAnimator(
                                        incomingEffect: _playIntroAnimations ? WidgetTransitionEffects.outgoingScaleUp(delay: const Duration(seconds: 2), duration: const Duration(seconds: 1)) : WidgetTransitionEffects(),
                                        child: ElevatedButton(
                                          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green[400])),
                                          onPressed: _isProcessingRematch ? null : () => revanchaFunction(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextScale(AppLocalizations.of(context)!.rematch,
                                                    style: TextStyle(
                                                      fontSize: rematchSize,
                                                      fontFamily: 'Poppins',
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 2,
                                                      color: Colors.green[900],
                                                    )),
                                                if (!premiumProvider.isPremium)
                                                  TextScale(AppLocalizations.of(context)!.watchAd,
                                                      style: TextStyle(
                                                        fontSize: watchAdSize,
                                                        fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.normal,
                                                        color: Colors.green[900],
                                                      )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> revanchaFunction() async {
    if (_isProcessingRematch) return;
    if (mounted) {
      setState(() {
        _isProcessingRematch = true;
      });
    } else {
      _isProcessingRematch = true;
    }

    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();

    final Partida? partidaSnapshot = _partidaFinalizada?.toPartidaForRematch();
    if (partidaSnapshot == null) {
      Toast.show(
        type: ToastType.error,
        context: context,
        message: AppLocalizations.of(context)!.rematchExecutionError,
      );
      _goHomeAndResetStack();
      return;
    }

    Future<void> restartAndGo() async {
      await MyLoading.show();
      final response = await partidaProvider.newPartida(partidaSnapshot, context);
      if (response.hasError!) {
        await MyLoading.close();
        Toast.show(
          type: ToastType.error,
          context: context,
          message: AppLocalizations.of(context)!.rematchExecutionError,
        );
        _goHomeAndResetStack();
        return;
      }
      final Partida nuevaPartida = response.data as Partida;
      partidaProvider.changePartidaEnTurno(nuevaPartida);
      await MyLoading.close();
      unawaited(
        Navigator.of(context).pushNamedAndRemoveUntil('partida', (route) => false),
      );
    }

    if (!premiumProvider.isPremium) {
      if (googleAdsProvider.rewardedAd == null) {
        googleAdsProvider.loadRewardedAd(RewardedAdLocation.revancha);
        Toast.show(
          type: ToastType.error,
          context: context,
          message: AppLocalizations.of(context)!.rematchExecutionError,
        );
        _goHomeAndResetStack();
        return;
      }

      bool rewardEarned = false;
      bool adFailed = false;
      googleAdsProvider.showRewardedAd(
        onCloseFunction: () {
          if (!context.mounted) return;
          if (rewardEarned) {
            unawaited(restartAndGo());
            return;
          }
          if (!adFailed) {
            Toast.show(
              type: ToastType.info,
              context: context,
              message: AppLocalizations.of(context)!.rewardNotCompletedRematch,
            );
          }
          googleAdsProvider.loadRewardedAd(RewardedAdLocation.revancha);
          _goHomeAndResetStack();
        },
        onRewardEarned: () {
          rewardEarned = true;
        },
        onAdFailed: () {
          if (!context.mounted) return;
          adFailed = true;
          Toast.show(
            type: ToastType.error,
            context: context,
            message: AppLocalizations.of(context)!.rematchExecutionError,
          );
          googleAdsProvider.loadRewardedAd(RewardedAdLocation.revancha);
          _goHomeAndResetStack();
        },
      );
    } else {
      await restartAndGo();
    }
  }
}
