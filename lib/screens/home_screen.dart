import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/banner_prefetch_service.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import '../widgets/force_update_modal.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ResponsiveApp.setMq(context);

    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    if (partidaProvider.isFirstSearch) partidaProvider.getPartidas();
    return const ScreenTracker(
      screenName: 'HomeScreen',
      child: MainHome(),
    );
  }
}

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome>
    with SingleTickerProviderStateMixin {
  late final PanelController panelController;
  late final AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateModal.showIfNeeded(context);
      _fabAnimController.forward();
      _showPendingAdIfNeeded();
    });
  }

  /// Muestra el anuncio intersticial si estaba pendiente (después de navegación)
  void _showPendingAdIfNeeded() {
    final googleAdsProvider = context.read<GoogleAdsProvider>();
    if (googleAdsProvider.showAdAfterNavigation) {
      googleAdsProvider.clearAdAfterNavigation();
      // Esperar a que la pantalla esté completamente cargada
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          googleAdsProvider.showInterstitialAd(onCloseFunction: () {
            googleAdsProvider.loadInterstitialAd();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void openMenuSlideUp() {
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
    slideUpProvider.openSlideUp(
        controller: panelController,
        bodyContent: _Menu(panelController: panelController),
        isDraggable: false);
  }

  void navigateToForm() {
    FormPartidaProvider formPartidaProvider =
        context.read<FormPartidaProvider>();
    formPartidaProvider.resetForm();
    Navigator.pushNamed(context, 'formulario');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        context.watch<SlideUpProvider>();
        context.watch<ThemeProvider>();

        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Layout(
            appBarTitle: l10n.myGames,
            appBarTrailing: _AnimatedMenuButton(onTap: openMenuSlideUp),
            bodyContent: _Body(panelController: panelController),
            panelController: panelController,
          ),
          floatingActionButton: Padding(
            padding: ResponsiveApp.only(bottom: 40),
            child: Visibility(
              visible:
                  !panelController.isAttached || panelController.isPanelClosed,
              child: ScaleTransition(
                scale: CurvedAnimation(
                    parent: _fabAnimController, curve: Curves.elasticOut),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.colorTercero.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: const CircleBorder(),
                    onPressed: () {
                      final PartidaProvider partidaProvider =
                          context.read<PartidaProvider>();
                      final PremiumProvider premiumProvider =
                          context.read<PremiumProvider>();

                      if (premiumProvider
                          .canCreateGame(partidaProvider.partidas.length)) {
                        navigateToForm();
                      } else {
                        Toast.show(
                            type: ToastType.info,
                            context: context,
                            message: l10n.freeVersionLimitGames(
                                PremiumProvider.freeMaxGames),
                            actionLabel: l10n.getPro,
                            onAction: () =>
                                Navigator.pushNamed(context, 'premium'));
                      }
                    },
                    child: const Icon(Icons.add_rounded,
                        size: 32, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AnimatedMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomIconButtom(
      iconSize: 26,
      iconColor: Colors.white,
      icon: Icons.menu_rounded,
      onTap: onTap,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: ListPartidas(panelController: panelController)),
        // Banner de anuncios
        const SizedBox(height: 10),
        Padding(
          padding: ResponsiveApp.only(bottom: 16),
          child: GoogleBannerAd(location: AdLocation.home),
        ),
      ],
    );
  }
}

class ListPartidas extends StatelessWidget {
  const ListPartidas({Key? key, required this.panelController})
      : super(key: key);
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final List<Partida> partidas = partidaProvider.partidas;

    if (partidas.isEmpty) {
      if (!partidaProvider.isFirstSearch) return const _EmptyState();
      return _LoadingState();
    }

    return ListView.builder(
      itemCount: partidas.length,
      padding: ResponsiveApp.symmetric(vertical: 30, horizontal: 20),
      physics: const ClampingScrollPhysics(),
      cacheExtent: 300,
      itemBuilder: (_, index) {
        final partida = partidas[index];
        return Padding(
          padding:
              EdgeInsets.only(bottom: index < partidas.length - 1 ? 16 : 100),
          child: FadeInUp(
            duration:
                Duration(milliseconds: 300 + (index < 5 ? index * 50 : 250)),
            child: PartidaCard(
              partida: partida,
              onTap: () {
                partidaProvider.changePartidaEnTurno(partida);
                Navigator.pushNamed(context, 'partida');
              },
              functionBorrar: (handler) async {
                final l10n = AppLocalizations.of(context)!;
                CustomAlertDialog.show(context,
                    menssage: l10n.confirmDeleteGame(partida.nombre!),
                    title: l10n.confirm,
                    dialogType: DialogType.error,
                    buttonsList: [
                      CustomActionsButtons.cancelButton({
                        'label': l10n.cancel,
                        'onTap': () {
                          Navigator.pop(context);
                          handler(false);
                        }
                      }),
                      CustomActionsButtons.aceptarButton({
                        'label': l10n.accept,
                        'onTap': () =>
                            removePartida(context, handler, partidas, index)
                      })
                    ]);
              },
              functionEditar: () {
                final FormPartidaProvider formPartidaProvider =
                    context.read<FormPartidaProvider>();
                final SlideUpProvider slideUp = context.read<SlideUpProvider>();
                context
                    .read<BannerPrefetchService>()
                    .ensurePrefetched(AdLocation.editarEntidad);
                formPartidaProvider.form.patchValue(partida.toMap());
                partidaProvider.partidaEditar = partida;
                slideUp.openSlideUp(
                    controller: panelController,
                    maxHeightFraction: 0.5,
                    bodyContent:
                        EditarEntidad(panelController: panelController));
              },
              functionReiniciar: () async {
                await partida.restartPartida();
                partidaProvider.refresh();
              },
              index: index,
            ),
          ),
        );
      },
    );
  }

  Future removePartida(BuildContext context, CompletionHandler handler,
      List<Partida> partidas, int index) async {
    Navigator.pop(context);
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    return partidaProvider.deletePartida(context, partida: partidas[index], handler: handler);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: ResponsiveApp.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemes.colorPrimero.withValues(alpha: 0.15),
                      AppThemes.colorTercero.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.gamepad,
                    size: 48,
                    color: AppThemes.colorPrimero.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Builder(builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    Text(
                      l10n.emptyGamesTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveApp.scaleText(20),
                        color: Preferences.isDarkMode
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppThemes.colorCuarto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.emptyGamesSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ResponsiveApp.scaleText(14),
                        height: 1.5,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding:
                          ResponsiveApp.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppThemes.colorPrimero.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppThemes.colorPrimero.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swipe_left_rounded,
                              size: 18, color: AppThemes.colorPrimero),
                          const SizedBox(width: 8),
                          Text(
                            l10n.swipeToEditOrDelete,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: ResponsiveApp.scaleText(12),
                              color: AppThemes.colorPrimero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: AppThemes.colorPrimero,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.loadingGames,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(14),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatefulWidget {
  final PanelController panelController;

  const _Menu({Key? key, required this.panelController}) : super(key: key);

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  final ScrollController _fallbackController = ScrollController();
  ScrollController? _currentController;

  ScrollController get _controller => _currentController ?? _fallbackController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inheritedController = SlideUpScrollController.of(context);
    if (inheritedController != null &&
        inheritedController != _currentController) {
      _currentController = inheritedController;
    }
  }

  @override
  void dispose() {
    _fallbackController.dispose();
    super.dispose();
  }

  void _closePanel() {
    final slideUpProvider = context.read<SlideUpProvider>();
    if (widget.panelController.isAttached) widget.panelController.close();
    slideUpProvider.closeSlideUp(
        controller: widget.panelController, isListener: true);
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final controller = _controller;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: ResponsiveApp.only(top: 5, bottom: 20),
      child: SingleChildScrollView(
        controller: controller,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con logo
            Padding(
              padding: ResponsiveApp.only(left: 4),
              child: Consumer<PremiumProvider>(
                builder: (context, premiumProvider, child) =>
                    _MenuHeader(isPremium: premiumProvider.isPremium),
              ),
            ),
            const SizedBox(height: 24),

            // Sección de Tema
            _MenuSection(
              icon: Icons.palette_outlined,
              title: AppLocalizations.of(context)!.appearance,
              child: Column(
                children: [
                  _ThemeToggleRow(
                    title: AppLocalizations.of(context)!.systemTheme,
                    subtitle: AppLocalizations.of(context)!.syncWithDevice,
                    value: Preferences.isSystemMode,
                    onChanged: (value) {
                      Preferences.isSystemMode = value;
                      Preferences.isDarkMode =
                          PlatformDispatcher.instance.platformBrightness ==
                              Brightness.dark;
                      themeProvider.changeCurrentTheme();
                      setState(() {});
                    },
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: Preferences.isSystemMode
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: const SizedBox(height: 0),
                    secondChild: Padding(
                      padding: ResponsiveApp.only(top: 12),
                      child: _ThemeSwitcher(
                        isDark: Preferences.isDarkMode,
                        onTap: () {
                          Preferences.isDarkMode = !Preferences.isDarkMode;
                          themeProvider.changeCurrentTheme();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sección de Idioma
            _MenuSection(
              icon: Icons.language_rounded,
              title: AppLocalizations.of(context)!.language,
              child: _LanguageSwitcher(),
            ),
            const SizedBox(height: 16),

            // Sección Premium
            Consumer<PremiumProvider>(
              builder: (context, premiumProvider, child) {
                return _PremiumCard(
                  isPremium: premiumProvider.isPremium,
                  simulatePremium: premiumProvider.simulatePremium,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    final slideUpProvider = context.read<SlideUpProvider>();
                    slideUpProvider.closeSlideUp(
                        controller: widget.panelController);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      navigator.pushNamed('premium');
                    });
                  },
                  onSimulateChanged: (value) =>
                      premiumProvider.setSimulatePremium(value),
                );
              },
            ),
            const SizedBox(height: 16),
            const _ReviewSection(),
            const SizedBox(height: 16),

            // Sección Acerca de
            _AboutButton(panelController: widget.panelController),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final bool isPremium;

  const _MenuHeader({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: Preferences.isDarkMode ? 0.3 : 0.12),
                blurRadius: 8,
                offset: const Offset(3, 3),
              ),
              BoxShadow(
                color: Colors.white
                    .withValues(alpha: Preferences.isDarkMode ? 0.08 : 0.75),
                blurRadius: 8,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              isPremium ? 'assets/icon/icon-pro.png' : 'assets/icon/icon.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(
                    color: Preferences.isDarkMode
                        ? Colors.white
                        : AppThemes.colorCuarto,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveApp.scaleText(22),
                    letterSpacing: 1,
                  ),
                ),
                if (isPremium) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        ResponsiveApp.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: ResponsiveApp.scaleText(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              AppLocalizations.of(context)!.configuration,
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _MenuSection(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveApp.all(16),
      decoration: BoxDecoration(
        color: Preferences.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Preferences.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: ResponsiveApp.all(8),
                decoration: BoxDecoration(
                  color: AppThemes.colorPrimero.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppThemes.colorPrimero),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Preferences.isDarkMode
                      ? Colors.white
                      : AppThemes.colorCuarto,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveApp.scaleText(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ThemeToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ThemeToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Preferences.isDarkMode
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.grey[800],
                  fontFamily: 'Poppins',
                  fontSize: ResponsiveApp.scaleText(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Poppins',
                  fontSize: ResponsiveApp.scaleText(11),
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppThemes.colorPrimero,
          activeTrackColor: AppThemes.colorPrimero.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeSwitcher({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveApp.all(4),
        decoration: BoxDecoration(
          color: Preferences.isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.wb_sunny_rounded,
              label: AppLocalizations.of(context)!.lightTheme,
              isSelected: !isDark,
            ),
            _ThemeOption(
              icon: Icons.nights_stay_rounded,
              label: AppLocalizations.of(context)!.darkTheme,
              isSelected: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _ThemeOption(
      {required this.icon, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: ResponsiveApp.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppThemes.colorPrimero : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: AppThemes.colorPrimero.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.grey[500],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[500],
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(13),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final bool isPremium;
  final bool simulatePremium;
  final VoidCallback onTap;
  final ValueChanged<bool> onSimulateChanged;

  const _PremiumCard({
    required this.isPremium,
    required this.simulatePremium,
    required this.onTap,
    required this.onSimulateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveApp.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemes.colorPrimero.withValues(alpha: 0.15),
              AppThemes.colorTercero.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemes.colorPrimero.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: ResponsiveApp.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.colorTercero.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/img/corona-pro.png',
                      width: 28, height: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isPremium
                                ? AppLocalizations.of(context)!.youArePro
                                : AppLocalizations.of(context)!.getPro,
                            style: TextStyle(
                              color: Preferences.isDarkMode
                                  ? Colors.white
                                  : AppThemes.colorCuarto,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveApp.scaleText(17),
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: ResponsiveApp.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 12, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context)!.active,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: 'Poppins',
                                      fontSize: ResponsiveApp.scaleText(10),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium
                            ? AppLocalizations.of(context)!.allFeaturesUnlocked
                            : AppLocalizations.of(context)!.noAdsUnlimitedGames,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Poppins',
                          fontSize: ResponsiveApp.scaleText(12),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  Container(
                    padding: ResponsiveApp.all(8),
                    decoration: BoxDecoration(
                      color: AppThemes.colorPrimero.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppThemes.colorPrimero),
                  ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Container(
                padding: ResponsiveApp.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bug_report_rounded,
                        size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.simulatePremiumDev,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontFamily: 'Poppins',
                          fontSize: ResponsiveApp.scaleText(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: simulatePremium,
                      onChanged: onSimulateChanged,
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {
        'code': 'es',
        'flag': '🇪🇸',
        'short': 'ES',
        'name': l10n.languageSpanish
      },
      {
        'code': 'en',
        'flag': '🇺🇸',
        'short': 'EN',
        'name': l10n.languageEnglish
      },
    ];

    return Container(
      padding: ResponsiveApp.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Preferences.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: localeProvider.currentCode,
          isExpanded: true,
          dropdownColor:
              Preferences.isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Preferences.isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
          selectedItemBuilder: (context) {
            return languages.map((lang) {
              return Row(
                children: [
                  Text(lang['flag']!,
                      style: TextStyle(fontSize: ResponsiveApp.scaleText(18))),
                  const SizedBox(width: 10),
                  Text(
                    lang['short']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveApp.scaleText(14),
                      color: Preferences.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: languages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang['code'],
              child: Row(
                children: [
                  Text(lang['flag']!,
                      style: TextStyle(fontSize: ResponsiveApp.scaleText(18))),
                  const SizedBox(width: 10),
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: ResponsiveApp.scaleText(14),
                      color: Preferences.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (code) {
            if (code != null) localeProvider.setLocale(code);
          },
        ),
      ),
    );
  }
}

class _MenuActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.15);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: ResponsiveApp.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: ResponsiveApp.all(8),
                decoration: BoxDecoration(
                  color: AppThemes.colorPrimero.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, size: 18, color: AppThemes.colorPrimero),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppThemes.colorCuarto,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveApp.scaleText(16),
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.grey[500],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatefulWidget {
  const _ReviewSection();

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  bool _isLoading = false;

  Future<void> _handleReviewTap() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final inAppReview = InAppReview.instance;
    try {
      final available = await inAppReview.isAvailable();
      if (available) {
        await inAppReview.requestReview();
      } else {
        Toast.info(context, message: l10n.reviewFallbackMessage);
      }
    } catch (error) {
      if (kDebugMode) debugPrint('Review request failed: $error');
      Toast.info(context, message: l10n.reviewFallbackMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _MenuActionButton(
      icon: FontAwesomeIcons.solidStar,
      title: l10n.reviewCardTitle,
      onTap: _handleReviewTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppThemes.colorPrimero),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Preferences.isDarkMode ? Colors.white70 : Colors.grey[500],
          ),
        ],
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  final PanelController panelController;

  const _AboutButton({required this.panelController});

  void _openAbout(BuildContext context) {
    final navigator = Navigator.of(context);
    final slideUpProvider = context.read<SlideUpProvider>();
    slideUpProvider.closeSlideUp(controller: panelController);
    Future.delayed(
        const Duration(milliseconds: 300), () => navigator.pushNamed('about'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _MenuActionButton(
      icon: FontAwesomeIcons.infoCircle,
      title: l10n.aboutTitle,
      onTap: () => _openAbout(context),
    );
  }
}
