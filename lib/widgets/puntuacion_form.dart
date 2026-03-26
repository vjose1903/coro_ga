import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/ganador.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import 'header_section.dart';
import 'widgets.dart';

class PuntuacionForm extends StatelessWidget {
  const PuntuacionForm({required this.panelController, super.key});
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return PuntuacionPage(panelController: panelController);
  }
}

class PuntuacionPage extends StatefulWidget {
  const PuntuacionPage({required this.panelController, super.key});
  final PanelController panelController;

  @override
  State<PuntuacionPage> createState() => _PuntuacionPageState();
}

class _PuntuacionPageState extends State<PuntuacionPage> {
  final ScrollController historialController = ScrollController();
  final TextEditingController puntuacionController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    historialController.dispose();
    puntuacionController.dispose();
    super.dispose();
  }

  void _maybeShowScoreInterstitial({
    required BuildContext context,
    required int previousScore,
    required int newScore,
    required int maxScore,
  }) {
    if (maxScore <= 0) return;
    final halfScore = maxScore / 2;
    if (newScore >= maxScore) return;
    if (newScore < halfScore) return;
    if (previousScore >= halfScore) return;

    final premiumProvider = context.read<PremiumProvider>();
    if (premiumProvider.isPremium) return;

    final googleAdsProvider = context.read<GoogleAdsProvider>();
    googleAdsProvider.showInterstitialAd(onCloseFunction: () {
      googleAdsProvider.loadInterstitialAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final partida = partidaProvider.partidaEnTurno;
    final jugador = jugadorProvider.jugadorEnTurno;
    if (partida == null || jugador == null) return const SizedBox.shrink();
    final maxScore = (partida.maxPuntuacion ?? 0).toInt();
    final bool hasTeclado = partida.tipo == 'Puntuación';
    final isDark = Preferences.isDarkMode;

    final historialSection = Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppThemes.themeColor_1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppThemes.colorCuarto.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _ListHistorial(historialController: historialController),
        ),
      ),
    );

    final actionButtons = Row(
      children: [
        Expanded(
          child: _ActionScoreButton(
            icon: Icons.remove_rounded,
            label: AppLocalizations.of(context)!.decrease,
            color: Colors.red[400]!,
            onTap: () async {
              final slideUpProvider = context.read<SlideUpProvider>();
              final previousScore = jugador.puntuacion ?? 0;
              final String puntuacion =
                  hasTeclado ? puntuacionController.text : '1';

              final int newPuntuacion = await changePuntuacion(
                jugadorProvider: jugadorProvider,
                puntuacion: puntuacion,
                tipo: 'reducir',
                context: context,
              );
              if (!context.mounted || newPuntuacion == 0) return;
              puntuacionController.text = '';
              slideUpProvider.closeSlideUp(controller: widget.panelController);
              _maybeShowScoreInterstitial(
                context: context,
                previousScore: previousScore,
                newScore: newPuntuacion,
                maxScore: maxScore,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionScoreButton(
            icon: Icons.add_rounded,
            label: AppLocalizations.of(context)!.increase,
            color: Colors.green,
            onTap: () async {
              final slideUpProvider = context.read<SlideUpProvider>();
              final previousScore = jugador.puntuacion ?? 0;
              final String puntuacion =
                  hasTeclado ? puntuacionController.text : '1';
              final int newPuntuacion = await changePuntuacion(
                jugadorProvider: jugadorProvider,
                puntuacion: puntuacion,
                tipo: 'aumentar',
                context: context,
              );
              if (!context.mounted || newPuntuacion == 0) return;
              puntuacionController.text = '';
              slideUpProvider.closeSlideUp(controller: widget.panelController);
              _maybeShowScoreInterstitial(
                context: context,
                previousScore: previousScore,
                newScore: newPuntuacion,
                maxScore: maxScore,
              );
              if (maxScore > 0 && newPuntuacion >= maxScore) {
                final ganador =
                    partida.getGanadorOrPerdedor(tipo: Estado.ganador);
                final finalizadaRes = await partidaProvider.finalizarPartida(
                  context,
                  partida: partida,
                  ganadorNombre: ganador['nombre']?.toString(),
                  motivo: 'max_score',
                  keepPartidaEnTurno: true,
                );
                if (finalizadaRes.hasError! || !context.mounted) return;
                final PartidaFinalizada finalizada =
                    finalizadaRes.data as PartidaFinalizada;
                unawaited(
                  GanadorScreen.showFullScreenDialog(
                    context,
                    partidaFinalizadaId: finalizada.id,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );

    // Usar ClipRect para evitar overflow visual cuando el panel se reduce
    return ResponsiveLayoutBuilder(
      useMediaQuery: true,
      builder: (context, constraints, info) {
        final useLandscapeLayout = info.useLandscapeLayout;
        final isWide = info.isWide;

        final useTwoColumns = useLandscapeLayout && hasTeclado;

        return SafeArea(
          top: false,
          bottom: false,
          left: useLandscapeLayout,
          right: useLandscapeLayout,
          child: ClipRect(
            child: useTwoColumns
                ? Row(
                    children: [
                      Expanded(
                        flex: 55,
                        child: Column(
                          children: [
                            _JugadorHeader(
                              nombre: jugadorProvider.nombreJugador,
                              puntuacion: jugador.puntuacion ?? 0,
                              canDelete: partida.jugadores!.length > 2,
                              panelController: widget.panelController,
                              useLandscapeLayout: useLandscapeLayout,
                              isWide: isWide,
                              onEdit: () {
                                jugadorProvider.jugadorEditar = jugador;
                                jugadorProvider.formJugador
                                    .patchValue(jugador.toMap());
                                _showEditarJugadorModal(
                                    context, useLandscapeLayout);
                              },
                              onDelete: () {
                                jugadorProvider.deleteJugador(context,
                                    jugador: jugador,
                                    panelController: widget.panelController,
                                    callBack: (value) {});
                              },
                            ),
                            const SizedBox(height: 12),
                            historialSection,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 45,
                        child: Column(
                          children: [
                            const Spacer(),
                            if (hasTeclado)
                              _KeyboardSection(
                                puntuacionController: puntuacionController,
                                errorText: _errorText,
                                useLandscapeLayout: useLandscapeLayout,
                                isWide: isWide,
                                onType: () {
                                  if (_errorText != null) {
                                    setState(() => _errorText = null);
                                  }
                                },
                              ),
                            if (hasTeclado) const SizedBox(height: 15),
                            actionButtons,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _JugadorHeader(
                        nombre: jugadorProvider.nombreJugador,
                        puntuacion: jugador.puntuacion ?? 0,
                        canDelete: partida.jugadores!.length > 2,
                        panelController: widget.panelController,
                        useLandscapeLayout: useLandscapeLayout,
                        isWide: isWide,
                        onEdit: () {
                          jugadorProvider.jugadorEditar = jugador;
                          jugadorProvider.formJugador
                              .patchValue(jugador.toMap());
                          _showEditarJugadorModal(context, useLandscapeLayout);
                        },
                        onDelete: () {
                          jugadorProvider.deleteJugador(context,
                              jugador: jugador,
                              panelController: widget.panelController,
                              callBack: (value) {});
                        },
                      ),
                      const SizedBox(height: 12),
                      historialSection,
                      const SizedBox(height: 12),
                      if (hasTeclado)
                        _KeyboardSection(
                          puntuacionController: puntuacionController,
                          errorText: _errorText,
                          useLandscapeLayout: useLandscapeLayout,
                          isWide: isWide,
                          onType: () {
                            if (_errorText != null) {
                              setState(() => _errorText = null);
                            }
                          },
                        ),
                      if (hasTeclado) const SizedBox(height: 15),
                      actionButtons,
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showEditarJugadorModal(BuildContext context, bool useLandscapeLayout) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final slideUpProvider = context.read<SlideUpProvider>();

    // Cerrar el slideUp cuando se abre el modal (sin limpiar jugadorEditar)
    slideUpProvider.closeSlideUp(
        controller: widget.panelController, skipClean: true);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppThemes.themeColor_2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: useLandscapeLayout ? screenWidth * 0.6 : double.infinity,
          height: screenHeight * 0.5,
          padding: const EdgeInsets.all(16),
          child: EditarEntidad(
            panelController: widget.panelController,
            onClose: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    ).then((_) {
      // Esperar al siguiente frame para asegurar que los datos estén sincronizados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        slideUpProvider.openSlideUp(
          controller: widget.panelController,
          bodyContent: PuntuacionForm(panelController: widget.panelController),
        );
      });
    });
  }

  Future<int> changePuntuacion(
      {required String puntuacion,
      required String tipo,
      required JugadorProvider jugadorProvider,
      required BuildContext context}) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final partida = partidaProvider.partidaEnTurno;
    final jugador = jugadorProvider.jugadorEnTurno;
    if (partida == null || jugador == null) return 0;

    if (puntuacion.isNotEmpty && puntuacion != '0') {
      final int puntuacionInt = int.parse(puntuacion);

      final int puntuacionActual = jugador.puntuacion ?? 0;

      if (tipo == 'reducir' && puntuacionActual - puntuacionInt < 0) {
        final l10n = AppLocalizations.of(context)!;
        final String msgErrorReducir = partida.tipo == 'Puntuación'
            ? l10n.minScoreWarning
            : l10n.minRoundWarning;
        Toast.show(
            type: ToastType.warning,
            context: context,
            title: l10n.warning,
            message: msgErrorReducir);

        return puntuacionActual;
      } else {
        await MyLoading.show();
        final SqlResponse response = await jugadorProvider.changePuntuacion(
            jugador: jugador, newPuntuacion: puntuacionInt, tipo: tipo);
        partidaProvider.refresh();
        jugadorProvider.changeJugadorEnTurno(response.data);
        await MyLoading.close();
        return response.data.puntuacion;
      }
    } else {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorText = puntuacion == '0'
            ? l10n.scoreMustBeGreaterThanZero
            : l10n.enterScoreToContinue;
      });
      return 0;
    }
  }
}

class _ListHistorial extends StatefulWidget {
  const _ListHistorial({required this.historialController});
  final ScrollController historialController;

  @override
  State<_ListHistorial> createState() => _ListHistorialState();
}

class _ListHistorialState extends State<_ListHistorial>
    with SlideUpAutoScrollMixin {
  int? _lastJugadorId;

  @override
  void initState() {
    super.initState();
    // Programar scroll inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAndScheduleScroll();
    });
  }

  @override
  void dispose() {
    cancelPendingScroll();
    super.dispose();
  }

  void _checkAndScheduleScroll() {
    final partidaProvider = context.read<PartidaProvider?>();
    final jugadorProvider = context.read<JugadorProvider?>();
    final partida = partidaProvider?.partidaEnTurno;
    final jugador = jugadorProvider?.jugadorEnTurno;
    if (partida != null &&
        jugador != null &&
        PartidaHistorialTimeline.buildEntriesForJugador(partida, jugador)
            .isNotEmpty) {
      _lastJugadorId = jugador.id;
      final effectiveController =
          getEffectiveController(context, widget.historialController);
      scheduleScrollToBottom(context, effectiveController);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        getEffectiveController(context, widget.historialController);
    final isDark = Preferences.isDarkMode;

    final PartidaProvider? partidaProvider = context.read<PartidaProvider?>();
    final JugadorProvider? jugadorProvider = context.watch<JugadorProvider?>();
    final Jugador? jugador = jugadorProvider?.jugadorEnTurno;
    final l10n = AppLocalizations.of(context)!;
    final partida = partidaProvider?.partidaEnTurno;
    if (partida == null || jugador == null) return const SizedBox.shrink();
    final msgNoRgistros = partida.tipo == 'Puntuación'
        ? l10n.noScoresRegistered
        : l10n.noRoundsRegistered;
    final entries =
        PartidaHistorialTimeline.buildEntriesForJugador(partida, jugador);

    // Scroll cuando cambia el jugador (después de init)
    if (_lastJugadorId != null &&
        _lastJugadorId != jugador.id &&
        entries.isNotEmpty) {
      _lastJugadorId = jugador.id;
      scheduleScrollToBottom(context, effectiveController);
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemes.colorPrimero.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconScale(Icons.history_rounded,
                  size: 32,
                  color: AppThemes.colorPrimero.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 12),
            TextScale(
              msgNoRgistros,
              size: 13,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[500],
              ),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: effectiveController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            separatorBuilder: (_, __) => Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.2),
              height: 1,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _HistorialItem(
                key: ValueKey(
                    'hist-${entries[index].historial?.id ?? 'placeholder'}_$index'),
                entry: entries[index],
                jugadorNombre: jugador.nombre!,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistorialItem extends StatefulWidget {
  const _HistorialItem({
    required this.entry,
    required this.jugadorNombre,
    required this.index,
    super.key,
  });
  final PartidaHistorialPlayerEntry entry;
  final String jugadorNombre;
  final int index;

  @override
  State<_HistorialItem> createState() => _HistorialItemState();
}

class _HistorialItemState extends State<_HistorialItem> {
  late SwipeActionController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = SwipeActionController();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlaceholder = widget.entry.isPlaceholder;
    final bool isAumentar = widget.entry.isIncrease;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final scoreText =
        isPlaceholder ? '0' : "${isAumentar ? '+' : '-'}${widget.entry.score}";
    final indexColor = Preferences.isDarkMode
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.18);
    final Color scoreColor = isPlaceholder
        ? (Preferences.isDarkMode
            ? Colors.white.withValues(alpha: 0.45)
            : Colors.grey[500]!)
        : (isAumentar ? Colors.green : Colors.red[400]!);

    if (isPlaceholder) {
      return Padding(
        padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 6 : 10, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextScale(
              '${widget.entry.turn}',
              size: 11,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: indexColor,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color:
                        (Preferences.isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconScale(
                    Icons.remove_rounded,
                    color: scoreColor,
                    size: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                TextScale(
                  scoreText,
                  size: 15,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SwipeActionCell(
        key: ValueKey(widget.entry.historial?.id),
        backgroundColor: Colors.transparent,
        controller: _swipeController,
        index: widget.index,
        trailingActions: [
          SwipeAction(
            icon: const IconScale(Icons.delete_outline_rounded,
                color: Colors.white, size: 20),
            title: AppLocalizations.of(context)!.delete,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(11),
                color: Colors.white),
            onTap: (CompletionHandler handler) async {
              final l10n = AppLocalizations.of(context)!;
              CustomAlertDialog.show(
                context,
                title: l10n.confirm,
                menssage: l10n.confirmDeleteScore(
                    widget.entry.score, widget.jugadorNombre),
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
                    'onTap': () async {
                      Navigator.pop(context);
                      await handler(true);
                      if (!context.mounted) return;
                      final jugadorProvider = context.read<JugadorProvider>();
                      final partidaProvider = context.read<PartidaProvider>();
                      await jugadorProvider.deleteHistorial(
                        historial: widget.entry.historial!,
                      );
                      partidaProvider.refresh();
                    }
                  }),
                ],
              );
            },
            color: Colors.red[400]!,
          ),
        ],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: () => _swipeController.openCellAt(
                index: widget.index, trailing: true),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 6 : 10, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextScale(
                    '${widget.entry.turn}',
                    size: 11,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: indexColor,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                        decoration: BoxDecoration(
                          color: (isAumentar ? Colors.green : Colors.red)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconScale(
                          isAumentar
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: isAumentar ? Colors.green : Colors.red[400],
                          size: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      TextScale(
                        scoreText,
                        size: 15,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: scoreColor,
                        ),
                      ),
                    ],
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

class _KeyboardSection extends StatelessWidget {
  const _KeyboardSection(
      {required this.puntuacionController,
      required this.onType,
      required this.useLandscapeLayout,
      required this.isWide,
      this.errorText});

  final TextEditingController puntuacionController;
  final String? errorText;
  final VoidCallback onType;
  final bool useLandscapeLayout;
  final bool isWide;

  void changePuntuacionValue(String value) {
    onType();
    if (value != 'DEL') {
      if (puntuacionController.text == '0' && value == '0') return;
      if (puntuacionController.text == '0' && value != '0') {
        puntuacionController.text = value;
      } else {
        puntuacionController.text = puntuacionController.text += value;
      }
    } else {
      if (puntuacionController.text.isNotEmpty) {
        String texto = puntuacionController.text;
        texto = texto.substring(0, texto.length - 1);
        puntuacionController.text = texto;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final padding = isSmallScreen ? 8.0 : 12.0;
    final spacing = isSmallScreen ? 6.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: AppThemes.colorCuarto.withValues(alpha: 0.1),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input de puntuación
          TextField(
            controller: puntuacionController,
            enabled: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ResponsiveApp.scaleText(
                  useLandscapeLayout ? (isWide ? 14 : 20) : 14),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppThemes.colorQuinto,
            ),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.scoreLabel,
              fillColor: AppThemes.inputDisabledColor,
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: useLandscapeLayout ? 7 : (isSmallScreen ? 2 : 4)),
              labelStyle: TextStyle(
                color: errorText != null
                    ? Colors.red[400]
                    : AppThemes.labelInputDisabledColor,
                fontFamily: 'Poppins',
              ),
              floatingLabelStyle: TextStyle(
                color: errorText != null
                    ? Colors.red[400]
                    : (isDark ? Colors.grey[400] : AppThemes.colorQuinto),
                fontSize: ResponsiveApp.scaleText(
                    useLandscapeLayout ? (isWide ? 14 : 20) : 14),
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: errorText != null
                        ? Colors.red[400]!
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: errorText != null
                        ? Colors.red[400]!
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: errorText != null
                        ? Colors.red[400]!
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // Usar el espacio existente para el error, así nada se mueve
          SizedBox(
            height: spacing,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (errorText != null)
                  Positioned(
                    top: 2,
                    child: TextScale(
                      errorText!,
                      size: 11,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Teclado
          CustomKeyboard(
            onChanged: (value) => changePuntuacionValue(value),
            tipo: KeyboardType.number,
            useLandscapeLayout: useLandscapeLayout,
            isWide: isWide,
          ),
        ],
      ),
    );
  }
}

// Widget para el header del jugador
class _JugadorHeader extends StatelessWidget {
  const _JugadorHeader({
    required this.nombre,
    required this.puntuacion,
    required this.canDelete,
    required this.panelController,
    required this.onEdit,
    required this.onDelete,
    required this.useLandscapeLayout,
    required this.isWide,
  });
  final String nombre;
  final int puntuacion;
  final bool canDelete;
  final PanelController panelController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return HeaderSection(
      panelController: panelController,
      icon: FontAwesomeIcons.user,
      iconBackgroundColor: AppThemes.colorPrimero,
      title: nombre,
      subtitle: AppLocalizations.of(context)!.playerScore(puntuacion),
      useLandscapeLayout:
          ResponsiveLayoutBuilder.maybeOf(context)?.useLandscapeLayout ??
              ResponsiveLayoutBuilder.resolveUseLandscapeLayout(context),
      isWide: ResponsiveLayoutBuilder.maybeOf(context)?.isWide ??
          ResponsiveLayoutBuilder.resolveIsWide(context),
      rightWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIconButton(
            icon: Icons.edit_outlined,
            useLandscapeLayout: useLandscapeLayout,
            isWide: isWide,
            onTap: onEdit,
          ),
          if (canDelete) ...[
            const SizedBox(width: 8),
            _MiniIconButton(
              icon: Icons.delete_outline_rounded,
              useLandscapeLayout: useLandscapeLayout,
              isWide: isWide,
              onTap: onDelete,
              isDestructive: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.icon,
    required this.onTap,
    required this.useLandscapeLayout,
    required this.isWide,
    this.isDestructive = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool useLandscapeLayout;
  final bool isWide;

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
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : (Preferences.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconScale(
            icon,
            size: useLandscapeLayout ? (isWide ? 16 : 14) : 18,
            color: isDestructive
                ? Colors.red[400]
                : (Preferences.isDarkMode ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class _ActionScoreButton extends StatelessWidget {
  const _ActionScoreButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconScale(icon, size: 22, color: Colors.white),
                const SizedBox(width: 8),
                TextScale(
                  label,
                  size: 15,
                  style: const TextStyle(
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
