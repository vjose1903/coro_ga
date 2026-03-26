import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../routes/route_observer.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'ganador.dart';

enum _PartidaViewMode { current, list }

extension _PartidaViewModeX on _PartidaViewMode {
  String get preferenceValue {
    switch (this) {
      case _PartidaViewMode.current:
        return 'current';
      case _PartidaViewMode.list:
        return 'list';
    }
  }
}

_PartidaViewMode _partidaViewModeFromPreference(String? value) {
  switch (value) {
    case 'list':
      return _PartidaViewMode.list;
    case 'current':
    default:
      return _PartidaViewMode.current;
  }
}

List<Jugador> _sortedJugadores(Partida partida) {
  final jugadores = List<Jugador>.from(partida.jugadores ?? <Jugador>[]);
  jugadores.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
  return jugadores;
}

Map<String, dynamic> _estadoConfig(String estado) {
  if (estado == Estado.ganador) {
    return {
      'icon': Icons.trending_up_rounded,
      'color': Colors.green,
      'bgColor': Colors.green.withValues(alpha: 0.1),
    };
  }

  if (estado == Estado.perdedor) {
    return {
      'icon': Icons.trending_down_rounded,
      'color': Colors.red[400],
      'bgColor': Colors.red.withValues(alpha: 0.1),
    };
  }

  if (estado == Estado.empate) {
    return {
      'icon': Icons.swap_horiz_rounded,
      'color': Colors.amber[700],
      'bgColor': Colors.amber.withValues(alpha: 0.1),
    };
  }

  return {
    'icon': Icons.remove_rounded,
    'color': Colors.grey,
    'bgColor': Colors.grey.withValues(alpha: 0.1),
  };
}

String _historyEmptyMessage(AppLocalizations l10n, Partida partida) {
  return partida.tipo == 'Puntuación'
      ? l10n.noScoresRegistered
      : l10n.noRoundsRegistered;
}

void _openJugadorScorePanel(
    BuildContext context, PanelController panelController, Jugador jugador) {
  final jugadorProvider = context.read<JugadorProvider>();
  final slideUpProvider = context.read<SlideUpProvider>();
  jugadorProvider.changeJugadorEnTurno(jugador);
  slideUpProvider.openSlideUp(
    controller: panelController,
    bodyContent: PuntuacionForm(panelController: panelController),
  );
}

class PartidaScreen extends StatefulWidget {
  const PartidaScreen({super.key});

  @override
  State<PartidaScreen> createState() => _PartidaScreenState();
}

class _PartidaScreenState extends State<PartidaScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late final PanelController panelController;
  late final AnimationController _fabAnimController;
  bool _showBanner = true;

  void _changePartidaViewMode(Partida partida, _PartidaViewMode viewMode) {
    final partidaId = partida.id;
    if (partidaId == null) return;
    Preferences.setPartidaViewMode(partidaId, viewMode.preferenceValue);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Resetear estado del panel al entrar a la pantalla
      if (mounted) {
        context
            .read<SlideUpProvider>()
            .closeSlideUp(controller: panelController, skipClean: true);
      }
      Future.delayed(const Duration(milliseconds: 300),
          () => _fabAnimController.forward());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {}

  @override
  void didPopNext() {
    context.read<SlideUpProvider>().closeSlideUp(
          controller: panelController,
          skipClean: true,
        );
    if (!_showBanner) {
      setState(() => _showBanner = true);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTracker(
      screenName: 'PartidaScreen',
      child: Consumer(
        builder: (BuildContext context, value, Widget? child) {
          context.watch<SlideUpProvider>();
          final partidaProvider = context.watch<PartidaProvider>();
          if (partidaProvider.partidaEnTurno == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final route = ModalRoute.of(context);
              if (route is! PageRoute || !route.isCurrent) return;
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                navigator.pushNamedAndRemoveUntil('home', (route) => false);
              }
            });
            return const SizedBox.shrink();
          }

          return ResponsiveLayoutBuilder(
            useMediaQuery: true,
            builder: (context, constraints, info) {
              final useLandscapeLayout = info.useLandscapeLayout;
              final isWide = info.isWide;
              final partida = partidaProvider.partidaEnTurno!;
              final viewMode = partida.id == null
                  ? _PartidaViewMode.current
                  : _partidaViewModeFromPreference(
                      Preferences.getPartidaViewMode(partida.id!));

              return Scaffold(
                body: _Body(
                  panelController: panelController,
                  showBanner: _showBanner,
                  useLandscapeLayout: useLandscapeLayout,
                  isWide: isWide,
                  viewMode: viewMode,
                  onViewModeChanged: (mode) =>
                      _changePartidaViewMode(partida, mode),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                floatingActionButton: Visibility(
                  visible: !panelController.isAttached ||
                      panelController.isPanelClosed,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                        parent: _fabAnimController, curve: Curves.elasticOut),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppThemes.colorPrimero,
                            AppThemes.colorTercero
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppThemes.colorTercero.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: const CircleBorder(),
                        onPressed: () {
                          final PartidaProvider partidaProvider =
                              context.read<PartidaProvider>();
                          final PremiumProvider premiumProvider =
                              context.read<PremiumProvider>();
                          final l10n = AppLocalizations.of(context)!;

                          if (premiumProvider
                              .canCreateGame(partidaProvider.partidas.length)) {
                            Navigator.pushNamed(context, 'formulario');
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
                        child: const IconScale(Icons.add_rounded,
                            size: 32, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: BottomBar(
                  useLandscapeLayout: useLandscapeLayout,
                  panelController: panelController,
                  child: NavigationBar(
                      useLandscapeLayout: useLandscapeLayout, isWide: isWide),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.panelController,
    required this.showBanner,
    required this.useLandscapeLayout,
    required this.isWide,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final PanelController panelController;
  final bool showBanner;
  final bool useLandscapeLayout;
  final bool isWide;
  final _PartidaViewMode viewMode;
  final ValueChanged<_PartidaViewMode> onViewModeChanged;
  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final FormPartidaProvider formPartidaProvider =
        context.read<FormPartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
    final Partida partida = partidaProvider.partidaEnTurno!;
    final bool compactHeight = ResponsiveApp.isSmallHeight;
    final l10n = AppLocalizations.of(context)!;

    final double topMargin = compactHeight
        ? (useLandscapeLayout ? 6 : 14)
        : (useLandscapeLayout ? 10 : 22);
    final mediaQuery = MediaQuery.of(context);
    final double bottomInset = mediaQuery.viewPadding.bottom;
    final double baseBottomMargin = compactHeight
        ? (useLandscapeLayout ? 17 : 60)
        : (useLandscapeLayout ? 25 : 90);
    const double bottomBarHeight = 65;
    final double landscapeBottomReserved = bottomBarHeight + bottomInset + 8;
    final double bottomMarginBase =
        useLandscapeLayout && baseBottomMargin < landscapeBottomReserved
            ? landscapeBottomReserved
            : baseBottomMargin;
    final double bottomMargin = bottomMarginBase + bottomInset;
    final double horizontalPadding = ResponsiveApp.scaleWidth(20);
    final double contentSpacing = ResponsiveApp.scaleHeight(20);
    final double betweenCardGap = compactHeight
        ? ResponsiveApp.scaleHeight(22)
        : ResponsiveApp.scaleHeight(25);
    final double adSpacing = ResponsiveApp.scaleHeight(15);

    return Layout(
        panelController: panelController,
        hasFooter: true,
        appBarTitle: partida.nombre,
        appBarLeading: CustomIconButtom(
          iconSize: useLandscapeLayout ? 19 : 20,
          iconColor: Colors.white,
          icon: Icons.arrow_back_ios_new,
          onTap: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigator.pushNamedAndRemoveUntil('home', (route) => false);
            }
          },
        ),
        appBarTrailing: CustomIconButtom(
          iconSize: useLandscapeLayout ? 19 : 20,
          iconColor: Colors.white,
          icon: Icons.edit_outlined,
          onTap: () {
            formPartidaProvider.form.patchValue(partida.toMap());
            partidaProvider.partidaEditar = partida;
            slideUpProvider.openSlideUp(
              controller: panelController,
              maxHeightFraction: useLandscapeLayout ? 0.9 : 0.5,
              bodyContent: EditarEntidad(panelController: panelController),
            );
          },
        ),
        bodyContent: Container(
            margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: useLandscapeLayout
                ? Row(
                    children: [
                      Flexible(
                        flex: isWide ? 40 : 45,
                        child: Column(
                          children: [
                            CustomEstadoPartida(
                              useLandscapeLayout: useLandscapeLayout,
                              isWide: isWide,
                            ),
                            SizedBox(height: contentSpacing),
                            const Spacer(),
                            if (partida.esSinMaxPuntuacion) ...[
                              _EndGameButton(
                                  label: l10n.endGame,
                                  onTap: () =>
                                      _confirmEndGame(context, partida),
                                  isWide: isWide,
                                  useLandscapeLayout: useLandscapeLayout),
                              SizedBox(height: adSpacing),
                            ],
                            Visibility(
                              visible: showBanner,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: const GoogleBannerAd(
                                location: AdLocation.partida,
                                usePadding: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveApp.scaleWidth(5)),
                      Flexible(
                        flex: isWide ? 60 : 55,
                        child: _JugadoresCard(
                          panelController: panelController,
                          expand: false,
                          useLandscapeLayout: useLandscapeLayout,
                          isWide: isWide,
                          viewMode: viewMode,
                          onViewModeChanged: onViewModeChanged,
                        ),
                      ),
                    ],
                  )
                : Column(children: [
                    CustomEstadoPartida(
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                    ),
                    SizedBox(height: contentSpacing),
                    _JugadoresCard(
                      panelController: panelController,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                      viewMode: viewMode,
                      onViewModeChanged: onViewModeChanged,
                    ),
                    SizedBox(height: betweenCardGap),
                    if (partida.esSinMaxPuntuacion) ...[
                      _EndGameButton(
                        label: l10n.endGame,
                        onTap: () => _confirmEndGame(context, partida),
                        isWide: isWide,
                        useLandscapeLayout: useLandscapeLayout,
                      ),
                      SizedBox(height: adSpacing),
                    ],
                    Visibility(
                      visible: showBanner,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: const GoogleBannerAd(
                        location: AdLocation.partida,
                      ),
                    ),
                    if (showBanner) SizedBox(height: adSpacing),
                  ])));
  }

  void _confirmEndGame(BuildContext context, Partida partida) {
    final l10n = AppLocalizations.of(context)!;
    final ganador = partida.getGanadorOrPerdedor(tipo: Estado.ganador);
    final partidaNombre = partida.nombre ?? l10n.noName;
    CustomAlertDialog.show(
      context,
      title: l10n.confirm,
      menssage: l10n.confirmEndGame(partidaNombre),
      dialogType: DialogType.warning,
      buttonsList: [
        CustomActionsButtons.cancelButton({
          'label': l10n.cancel,
          'onTap': () => Navigator.pop(context),
        }),
        CustomActionsButtons.aceptarButton({
          'label': l10n.endGame,
          'onTap': () async {
            Navigator.pop(context);
            final finalizadaRes =
                await context.read<PartidaProvider>().finalizarPartida(
                      context,
                      partida: partida,
                      ganadorNombre: ganador['nombre']?.toString(),
                      motivo: 'manual',
                      keepPartidaEnTurno: true,
                    );
            if (finalizadaRes.hasError!) return;
            final PartidaFinalizada finalizada =
                finalizadaRes.data as PartidaFinalizada;
            if (!context.mounted) return;
            unawaited(
              GanadorScreen.showFullScreenDialog(
                context,
                partidaFinalizadaId: finalizada.id,
              ),
            );
          },
        }),
      ],
    );
  }
}

class _EndGameButton extends StatelessWidget {
  const _EndGameButton(
      {required this.label,
      required this.onTap,
      required this.isWide,
      required this.useLandscapeLayout});
  final String label;
  final VoidCallback onTap;
  final bool isWide;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: useLandscapeLayout ? 10 : 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[600]!, Colors.red[400]!],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const IconScale(Icons.flag_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              TextScale(
                label,
                size: isWide ? 14 : 15,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JugadoresCard extends StatelessWidget {
  const _JugadoresCard({
    required this.panelController,
    required this.useLandscapeLayout,
    required this.isWide,
    required this.viewMode,
    required this.onViewModeChanged,
    this.expand = true,
  });
  final PanelController panelController;
  final bool expand;
  final bool useLandscapeLayout;
  final bool isWide;
  final _PartidaViewMode viewMode;
  final ValueChanged<_PartidaViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    openSlideUp() {
      final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();
      final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
      jugadorProvider.formJugador.reset();
      slideUpProvider.openSlideUp(
          controller: panelController,
          bodyContent: AddJugadorPartida(panelController: panelController));
    }

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppThemes.themeColor_2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Preferences.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemes.colorCuarto
                .withValues(alpha: Preferences.isDarkMode ? 0.2 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header con botones
            Row(
              children: [
                _ActionButton(
                  icon: Icons.history_rounded,
                  useLandscapeLayout: useLandscapeLayout,
                  isWide: isWide,
                  onTap: () {
                    final SlideUpProvider slideUpProvider =
                        context.read<SlideUpProvider>();
                    slideUpProvider.openSlideUp(
                        controller: panelController,
                        bodyContent:
                            HistorialGeneral(panelController: panelController));
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ViewModeToggle(
                    useLandscapeLayout: useLandscapeLayout,
                    isWide: isWide,
                    selectedMode: viewMode,
                    onChanged: onViewModeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.manage_accounts_rounded,
                  useLandscapeLayout: useLandscapeLayout,
                  isWide: isWide,
                  isPrimary: true,
                  onTap: openSlideUp,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de jugadores
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: viewMode == _PartidaViewMode.list
                    ? JugadoresHistoryList(
                        key: const ValueKey('partida_history_list'),
                        panelController: panelController,
                        useLandscapeLayout: useLandscapeLayout,
                        isWide: isWide,
                      )
                    : JugadoresList(
                        key: const ValueKey('partida_cards_list'),
                        panelController: panelController,
                        useLandscapeLayout: useLandscapeLayout,
                        isWide: isWide,
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!expand) return card;
    return Expanded(child: card);
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.useLandscapeLayout,
    required this.isWide,
    required this.selectedMode,
    required this.onChanged,
  });

  final bool useLandscapeLayout;
  final bool isWide;
  final _PartidaViewMode selectedMode;
  final ValueChanged<_PartidaViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Preferences.isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Preferences.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ViewModeOption(
              icon: Icons.grid_view_rounded,
              isSelected: selectedMode == _PartidaViewMode.current,
              useLandscapeLayout: useLandscapeLayout,
              isWide: isWide,
              onTap: () => onChanged(_PartidaViewMode.current),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ViewModeOption(
              icon: Icons.view_list_rounded,
              isSelected: selectedMode == _PartidaViewMode.list,
              useLandscapeLayout: useLandscapeLayout,
              isWide: isWide,
              onTap: () => onChanged(_PartidaViewMode.list),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModeOption extends StatelessWidget {
  const _ViewModeOption({
    required this.icon,
    required this.isSelected,
    required this.useLandscapeLayout,
    required this.isWide,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final bool useLandscapeLayout;
  final bool isWide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: useLandscapeLayout ? 4 : 5),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconScale(
            icon,
            size: isWide ? 15 : 16,
            color: isSelected
                ? Colors.white
                : (Preferences.isDarkMode ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.useLandscapeLayout,
    required this.isWide,
    required this.onTap,
    this.isPrimary = false,
  });
  final IconData icon;
  final bool useLandscapeLayout;
  final bool isWide;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                  )
                : null,
            color: isPrimary
                ? null
                : (Preferences.isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconScale(
            icon,
            size: isWide ? 16 : 13,
            color: isPrimary
                ? Colors.white
                : (Preferences.isDarkMode ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class JugadoresList extends StatelessWidget {
  const JugadoresList(
      {required this.panelController,
      required this.useLandscapeLayout,
      required this.isWide,
      super.key});
  final PanelController panelController;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno!;
    final jugadores = _sortedJugadores(partida);

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalSpacing = 10.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final columns = useLandscapeLayout && availableWidth >= 700 ? 3 : 2;
        final columnWidth =
            (availableWidth - horizontalSpacing * (columns - 1)) / columns;
        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Wrap(
              runSpacing: 10,
              spacing: horizontalSpacing,
              children: jugadores.asMap().entries.map((entry) {
                final index = entry.key;
                final jugador = entry.value;

                final jugadorCard = JugadorInfo(
                  jugador: jugador,
                  panelController: panelController,
                  useLandscapeLayout: useLandscapeLayout,
                  isWide: isWide,
                );

                return SizedBox(
                  width: columnWidth,
                  child: partidaProvider.isChangePartida
                      ? ElasticIn(
                          key: ValueKey('${partida.id}_${jugador.id}'),
                          delay: Duration(
                              milliseconds:
                                  100 * index), // Reducido de 100ms a 50ms
                          child: jugadorCard)
                      : jugadorCard,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class JugadoresHistoryList extends StatelessWidget {
  const JugadoresHistoryList({
    required this.panelController,
    required this.useLandscapeLayout,
    required this.isWide,
    super.key,
  });

  final PanelController panelController;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final partidaProvider = context.watch<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno!;
    final jugadores = _sortedJugadores(partida);

    if (jugadores.isEmpty) {
      return _HistoryEmptyState(
          message:
              _historyEmptyMessage(AppLocalizations.of(context)!, partida));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (jugadores.length <= 2) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < jugadores.length; index++) ...[
                Expanded(
                  child: _AnimatedHistoryPlayerCard(
                    partida: partida,
                    jugador: jugadores[index],
                    index: index,
                    isAnimated: partidaProvider.isChangePartida,
                    child: _JugadorHistoryPanel(
                      jugador: jugadores[index],
                      partida: partida,
                      panelController: panelController,
                      useLandscapeLayout: useLandscapeLayout,
                      isWide: isWide,
                      showFullHistory: true,
                    ),
                  ),
                ),
                if (index < jugadores.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;
        const spacing = 12.0;
        final columns = useLandscapeLayout && availableWidth >= 700 ? 3 : 2;
        final cardHeight = useLandscapeLayout
            ? availableHeight
            : (availableHeight - spacing) / 2;

        return GridView.builder(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: jugadores.length,
          itemBuilder: (context, index) => _AnimatedHistoryPlayerCard(
            partida: partida,
            jugador: jugadores[index],
            index: index,
            isAnimated: partidaProvider.isChangePartida,
            child: _JugadorHistoryPanel(
              jugador: jugadores[index],
              partida: partida,
              panelController: panelController,
              useLandscapeLayout: useLandscapeLayout,
              isWide: isWide,
              showFullHistory: false,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedHistoryPlayerCard extends StatelessWidget {
  const _AnimatedHistoryPlayerCard({
    required this.partida,
    required this.jugador,
    required this.index,
    required this.isAnimated,
    required this.child,
  });

  final Partida partida;
  final Jugador jugador;
  final int index;
  final bool isAnimated;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isAnimated) return child;

    return ElasticIn(
      key: ValueKey('${partida.id}_${jugador.id}_history'),
      delay: Duration(milliseconds: 100 * index),
      child: child,
    );
  }
}

class JugadorInfo extends StatelessWidget {
  const JugadorInfo(
      {required this.jugador,
      required this.panelController,
      required this.useLandscapeLayout,
      required this.isWide,
      super.key});
  final Jugador jugador;
  final PanelController panelController;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final estado = partidaProvider.partidaEnTurno!.getJugadorEstatus(jugador);
    final config = _estadoConfig(estado);

    return _JugadorCard(
      jugador: jugador,
      estado: estado,
      config: config,
      useLandscapeLayout: useLandscapeLayout,
      isWide: isWide,
      onTap: () => _openJugadorScorePanel(context, panelController, jugador),
    );
  }
}

class _JugadorHistoryPanel extends StatefulWidget {
  const _JugadorHistoryPanel({
    required this.jugador,
    required this.partida,
    required this.panelController,
    required this.useLandscapeLayout,
    required this.isWide,
    required this.showFullHistory,
  });

  final Jugador jugador;
  final Partida partida;
  final PanelController panelController;
  final bool useLandscapeLayout;
  final bool isWide;
  final bool showFullHistory;

  @override
  State<_JugadorHistoryPanel> createState() => _JugadorHistoryPanelState();
}

class _JugadorHistoryPanelState extends State<_JugadorHistoryPanel> {
  late final ScrollController _historyScrollController;
  int? _lastGlobalTurnCount;

  @override
  void initState() {
    super.initState();
    _historyScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  @override
  void didUpdateWidget(covariant _JugadorHistoryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jugador.id != widget.jugador.id ||
        oldWidget.jugador.historialJugadas?.length !=
            widget.jugador.historialJugadas?.length ||
        oldWidget.showFullHistory != widget.showFullHistory) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
    }
  }

  void _scrollToLatest() {
    if (!mounted || !_historyScrollController.hasClients) return;
    final position = _historyScrollController.position;
    _historyScrollController.jumpTo(position.maxScrollExtent);
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.partida.getJugadorEstatus(widget.jugador);
    final config = _estadoConfig(estado);
    final allEntries = PartidaHistorialTimeline.buildEntriesForJugador(
      widget.partida,
      widget.jugador,
    );
    final globalTurnCount = PartidaHistorialTimeline.buildTurns(widget.partida).length;
    final entries = widget.showFullHistory
        ? allEntries
        : allEntries
            .skip((allEntries.length - 4).clamp(0, allEntries.length))
            .toList();
    final isDark = Preferences.isDarkMode;
    final currentScore = widget.jugador.puntuacion ?? 0;

    if (_lastGlobalTurnCount != globalTurnCount) {
      _lastGlobalTurnCount = globalTurnCount;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openJugadorScorePanel(
          context,
          widget.panelController,
          widget.jugador,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(widget.useLandscapeLayout ? 6 : 7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.useLandscapeLayout ? 8 : 10,
                  vertical: widget.useLandscapeLayout ? 6 : 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E).withValues(
                    alpha: isDark ? 0.92 : 0.82,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: (config['color'] as Color).withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextScale(
                              widget.jugador.nombre ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              size: widget.useLandscapeLayout ? 12 : 13,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5B7CFF),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextScale(
                              currentScore.toString(),
                              size: widget.useLandscapeLayout ? 21 : 24,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: config['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: (config['color'] as Color)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconScale(
                            config['icon'] as IconData,
                            size: 11,
                            color: config['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: entries.isEmpty
                    ? _HistoryEmptyState(
                        message: _historyEmptyMessage(
                            AppLocalizations.of(context)!, widget.partida))
                    : widget.showFullHistory
                        ? ListView.separated(
                            controller: _historyScrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 6),
                            itemCount: entries.length,
                            separatorBuilder: (_, __) => Divider(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.withValues(alpha: 0.15),
                              height: 12,
                            ),
                            itemBuilder: (context, index) => _ScoreHistoryTile(
                              entry: entries[index],
                              compact: false,
                            ),
                          )
                        : ListView.separated(
                            controller: _historyScrollController,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: entries.length,
                            separatorBuilder: (_, __) => Divider(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.withValues(alpha: 0.15),
                              height: 6,
                            ),
                            itemBuilder: (context, index) => _ScoreHistoryTile(
                              entry: entries[index],
                              compact: true,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreHistoryTile extends StatelessWidget {
  const _ScoreHistoryTile({
    required this.entry,
    required this.compact,
  });

  final PartidaHistorialPlayerEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final valueColor = entry.isPlaceholder
        ? (Preferences.isDarkMode
            ? Colors.white.withValues(alpha: 0.55)
            : Colors.black.withValues(alpha: 0.45))
        : (entry.isIncrease ? const Color(0xFF5B7CFF) : Colors.red[300]!);
    final indexColor = Preferences.isDarkMode
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.18);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 1 : 4,
      ),
      child: Row(
        children: [
          TextScale(
            '${entry.turn}',
            size: compact ? 10.5 : 11.5,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: indexColor,
            ),
          ),
          const Spacer(),
          TextScale(
            entry.isPlaceholder
                ? '0'
                : '${entry.isIncrease ? '+' : '-'}${entry.score}',
            size: compact ? 12 : 14,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF5B7CFF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconScale(
                Icons.history_rounded,
                size: 20,
                color: const Color(0xFF5B7CFF).withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextScale(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            size: 10.5,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[500],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _JugadorCard extends StatelessWidget {
  const _JugadorCard({
    required this.jugador,
    required this.estado,
    required this.config,
    required this.useLandscapeLayout,
    required this.isWide,
    required this.onTap,
  });
  final Jugador jugador;
  final String estado;
  final Map<String, dynamic> config;
  final bool useLandscapeLayout;
  final bool isWide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isWinner = estado == Estado.ganador;
    final bool isLoser = estado == Estado.perdedor;
    final bool compactWidth = ResponsiveApp.isSmallWidth;
    final double cardHeight = (useLandscapeLayout
        ? ResponsiveApp.scaleWidth(isWide ? 65 : 45)
        : ResponsiveApp.scaleHeight(130));
    final double defaultCardWidth =
        ResponsiveApp.size.width * (compactWidth ? 0.48 : 0.4);
    final double cardWidth = defaultCardWidth;
    final double contentPadding =
        ResponsiveApp.scaleWidth(useLandscapeLayout ? 5 : 12);
    final double nameFontSize = useLandscapeLayout ? 15 : 14;
    final double scoreFontSize = useLandscapeLayout ? 32 : 42;

    final double iconSize = useLandscapeLayout ? 11 : 14;
    final double iconPadding =
        ResponsiveApp.scaleWidth(useLandscapeLayout ? 3 : 4);

    return Container(
      height: cardHeight,
      width: cardWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Preferences.isDarkMode
              ? [const Color(0xFF2A2D3E), const Color(0xFF1F2130)]
              : [const Color(0xFFE8ECFF), const Color(0xFFD4DBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner
              ? Colors.green.withValues(alpha: 0.4)
              : isLoser
                  ? Colors.red.withValues(alpha: 0.3)
                  : (Preferences.isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppThemes.colorPrimero.withValues(alpha: 0.2)),
          width: isWinner || isLoser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isWinner
                ? Colors.green.withValues(alpha: 0.2)
                : isLoser
                    ? Colors.red.withValues(alpha: 0.15)
                    : AppThemes.colorCuarto.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Nombre (arriba izquierda)
                Align(
                  alignment: Alignment.topLeft,
                  child: TextScale(
                    jugador.nombre!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    size: nameFontSize,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Preferences.isDarkMode
                          ? AppThemes.colorPrimero
                          : AppThemes.colorTercero,
                    ),
                  ),
                ),
                // Icono de estado (abajo derecha)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: config['bgColor'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconScale(
                      config['icon'],
                      size: iconSize,
                      color: config['color'],
                    ),
                  ),
                ),
                // Puntuación (centrada y por encima del resto)
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isWinner
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : isLoser
                              ? [Colors.red[300]!, Colors.red[500]!]
                              : [
                                  AppThemes.colorPrimero,
                                  AppThemes.colorTercero
                                ],
                    ).createShader(bounds),
                    child: TextScale(
                      jugador.puntuacion.toString(),
                      size: scoreFontSize,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

class NavigationBar extends StatefulWidget {
  const NavigationBar(
      {required this.useLandscapeLayout, required this.isWide, super.key});
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  late List<int> visibleIndeces = [];

  @override
  void initState() {
    super.initState();

    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => scrollToGame(context));

    itemPositionsListener.itemPositions.addListener(() {
      visibleIndeces = itemPositionsListener.itemPositions.value
          .map((item) => item.index)
          .toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scrollToGame(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    final int selectedIndex = partidaProvider.partidas.indexWhere(
        (partida) => partida.id == partidaProvider.partidaEnTurno!.id);

    // Usar post frame callback en lugar de delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (partidaProvider.partidas.length > 3 &&
          visibleIndeces.isNotEmpty &&
          ((selectedIndex <= visibleIndeces.first) ||
              (selectedIndex >= visibleIndeces.last))) {
        itemScrollController.scrollTo(
            index: selectedIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            alignment: 0.4);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final List<Partida> partidas = partidaProvider.partidas;

    final double paddingLeft =
        widget.useLandscapeLayout ? (widget.isWide ? 20 : 35) : 20;

    if (partidas.isNotEmpty) {
      return ScrollablePositionedList.separated(
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: partidas.length,
          padding: EdgeInsets.only(left: paddingLeft, right: 200),
          itemBuilder: (context, index) => _Chip(
              partida: partidas[index],
              scrollToGame: scrollToGame,
              isWide: widget.isWide,
              useLandscapeLayout: widget.useLandscapeLayout));
    } else {
      return Container();
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.partida,
      required this.scrollToGame,
      required this.isWide,
      required this.useLandscapeLayout});
  final Partida? partida;
  final Function scrollToGame;
  final bool isWide;
  final bool useLandscapeLayout;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final bool isSelected = partida!.id == partidaProvider.partidaEnTurno!.id;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                )
              : null,
          color: isSelected
              ? null
              : (Preferences.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(
                  color: Preferences.isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppThemes.colorTercero.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              if (!isSelected) {
                partidaProvider.changePartidaEnTurno(partida!);
                scrollToGame(context);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 18, vertical: useLandscapeLayout ? 6 : 10),
              child: TextScale(
                partida!.nombre!,
                size: isWide ? 14 : 16,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isSelected
                      ? Colors.white
                      : (Preferences.isDarkMode
                          ? Colors.white70
                          : Colors.grey[700]),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
