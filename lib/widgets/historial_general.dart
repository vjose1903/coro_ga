import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/helpers.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/ganador.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import 'widgets.dart';
import 'layout.dart';
import 'slide_up_header.dart';
import '../utils/utils.dart';
import '../helpers/ad_locations.dart';
import 'package:provider/provider.dart';

class HistorialGeneral extends StatefulWidget {
  const HistorialGeneral({super.key, required this.panelController});
  final PanelController panelController;

  @override
  State<HistorialGeneral> createState() => _HistorialGeneralState();
}

class _HistorialGeneralState extends State<HistorialGeneral> with SlideUpAutoScrollMixin {
  final TextEditingController puntuacionController = TextEditingController();
  final ScrollController historialController = ScrollController();
  final GoogleBannerAd anuncio = const GoogleBannerAd(location: AdLocation.puntuacion);
  Jugador? jugadorSeleccionado;
  String? _errorText;

  @override
  void dispose() {
    cancelPendingScroll();
    puntuacionController.dispose();
    historialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final Partida partida = partidaProvider.partidaEnTurno!;
    final List<Jugador> jugadores = partida.jugadores ?? [];
    final isDark = Preferences.isDarkMode;

    jugadorSeleccionado ??= jugadores.isNotEmpty ? jugadores.first : null;

    // Combinar todos los historiales
    final List<_HistorialConJugador> todosHistoriales = [];
    for (final jugador in jugadores) {
      if (jugador.historialJugadas != null) {
        for (final historial in jugador.historialJugadas!) {
          todosHistoriales.add(_HistorialConJugador(jugador: jugador, historial: historial));
        }
      }
    }
    todosHistoriales.sort((a, b) => a.historial.id!.compareTo(b.historial.id!));

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final spacingLg = isSmallScreen ? 8.0 : 16.0;
    final spacingMd = isSmallScreen ? 6.0 : 12.0;

    return Column(
      children: [
        // Header - arrastrable para cerrar el panel
        _HistorialHeader(
          cantRegistros: todosHistoriales.length,
          panelController: widget.panelController,
        ),
        SizedBox(height: spacingLg),

        // Selector de jugador
        _JugadorSelector(
          jugadores: jugadores,
          jugadorSeleccionado: jugadorSeleccionado,
          onChanged: (jugador) => setState(() => jugadorSeleccionado = jugador),
        ),
        SizedBox(height: spacingMd),

        // Lista de historial
        Flexible(
          flex: 2,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight * (isSmallScreen ? 0.12 : 0.18),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppThemes.themeColor_1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _ListHistorialGeneral(
                  historiales: todosHistoriales,
                  historialController: historialController,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: spacingMd),

        // Teclado y campo de puntuación
        if (partida.tipo == 'Puntuación') ...[
          _KeyboardSection(
            puntuacionController: puntuacionController,
            errorText: _errorText,
            onType: () {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),
          const SizedBox(height: 15),
        ],

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: _ActionScoreButton(
                icon: Icons.remove_rounded,
                label: AppLocalizations.of(context)!.decrease,
                color: Colors.red[400]!,
                onTap: () => _changePuntuacion(
                  context: context,
                  jugadorProvider: jugadorProvider,
                  partidaProvider: partidaProvider,
                  tipo: 'reducir',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionScoreButton(
                icon: Icons.add_rounded,
                label: AppLocalizations.of(context)!.increase,
                color: const Color(0xFF4CAF50),
                onTap: () => _changePuntuacion(
                  context: context,
                  jugadorProvider: jugadorProvider,
                  partidaProvider: partidaProvider,
                  tipo: 'aumentar',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Anuncio (separado de los botones de acción)
        anuncio,
      ],
    );
  }

  Future<void> _changePuntuacion({
    required BuildContext context,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required String tipo,
  }) async {
    final scrollController = getEffectiveController(context, historialController);
    final l10n = AppLocalizations.of(context)!;
    if (jugadorSeleccionado == null) {
      setState(() {
        _errorText = l10n.selectPlayer;
      });
      return;
    }

    final String puntuacion = partidaProvider.partidaEnTurno!.tipo == 'Puntuación' ? puntuacionController.text : '1';

    if (puntuacion.isEmpty || puntuacion == '0') {
      setState(() {
        _errorText = puntuacion == '0' ? l10n.scoreMustBeGreaterThanZero : l10n.enterScoreToContinue;
      });
      return;
    }

    final int puntuacionInt = int.parse(puntuacion);
    final int puntuacionActual = jugadorSeleccionado!.puntuacion!;
    final maxScore = partidaProvider.partidaEnTurno!.maxPuntuacion!.toInt();

    if (tipo == 'reducir' && puntuacionActual - puntuacionInt < 0) {
      final String msgError = partidaProvider.partidaEnTurno!.tipo == 'Puntuación' ? l10n.minScoreWarning : l10n.minRoundWarning;
      Toast.show(type: ToastType.warning, context: context, title: l10n.warning, message: msgError);
      return;
    }

    MyLoading.show();

    // Cambiar temporalmente el jugador en turno para usar el método existente
    final Jugador? jugadorAnterior = jugadorProvider.jugadorEnTurno;
    jugadorProvider.changeJugadorEnTurno(jugadorSeleccionado!);

    final SqlResponse response = await jugadorProvider.changePuntuacion(
      jugador: jugadorSeleccionado!,
      newPuntuacion: puntuacionInt,
      tipo: tipo,
    );

    partidaProvider.refresh();

    // Restaurar jugador anterior si existía
    if (jugadorAnterior != null && jugadorAnterior.id != jugadorSeleccionado!.id) {
      jugadorProvider.changeJugadorEnTurno(jugadorAnterior);
    }

    MyLoading.close();

    if (!response.hasError!) {
      puntuacionController.text = '';
      setState(() {}); // Refrescar la lista

      final int newPuntuacion = response.data.puntuacion;
      if (newPuntuacion >= maxScore) {
        final slideUpProvider = context.read<SlideUpProvider>();
        slideUpProvider.closeSlideUp(
          controller: widget.panelController,
        );
        
        Navigator.push(
          context,
          PageRouteBuilder(
            settings: RouteSettings(arguments: {
              'partida': partidaProvider.partidaEnTurno!.nombre,
              'jugador': jugadorSeleccionado!.nombre,
            }),
            pageBuilder: (context, animation, secondaryAnimation) => const GanadorScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else if (puntuacionActual < (maxScore / 2) && newPuntuacion >= (maxScore / 2)) {
        final premiumProvider = context.read<PremiumProvider>();
        if (!premiumProvider.isPremium) {
          final googleAdsProvider = context.read<GoogleAdsProvider>();
          googleAdsProvider.showInterstitialAd(onCloseFunction: () {
            googleAdsProvider.loadInterstitialAd();
          });
        }
      }

      // Scroll al final usando el mixin
      scheduleScrollToBottom(context, scrollController);
    }
  }
}

class _HistorialConJugador {
  _HistorialConJugador({required this.jugador, required this.historial});
  final Jugador jugador;
  final HistorialJugada historial;
}

// ============================================
// WIDGETS PRIVADOS
// ============================================

class _HistorialHeader extends StatelessWidget {
  const _HistorialHeader({required this.cantRegistros, required this.panelController});

  final int cantRegistros;
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return SlideUpHeader(
      panelController: panelController,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.colorPrimero.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.clockRotateLeft, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.generalHistory,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: ResponsiveApp.scaleText(14),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppThemes.colorQuinto,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppLocalizations.of(context)!.records(cantRegistros),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: ResponsiveApp.scaleText(11),
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JugadorSelector extends StatelessWidget {
  const _JugadorSelector({
    required this.jugadores,
    required this.jugadorSeleccionado,
    required this.onChanged,
  });

  final List<Jugador> jugadores;
  final Jugador? jugadorSeleccionado;
  final Function(Jugador?) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final avatarSize = isSmallScreen ? 24.0 : 28.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemes.inputColor,
        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 15),
      ),
      child: DropdownButton<Jugador>(
        value: jugadorSeleccionado,
        isExpanded: true,
        isDense: isSmallScreen,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppThemes.themeColor_1 : Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          size: isSmallScreen ? 20 : 24,
        ),
        items: jugadores.map((jugador) {
          return DropdownMenuItem<Jugador>(
            value: jugador,
            child: Row(
              children: [
                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  ),
                  child: Center(
                    child: Text(
                      jugador.nombre != null && jugador.nombre!.isNotEmpty ? jugador.nombre![0].toUpperCase() : '?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ResponsiveApp.scaleText(12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                // Nombre
                Expanded(
                  child: Text(
                    jugador.nombre!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: ResponsiveApp.scaleText(14),
                      color: isDark ? Colors.white : AppThemes.colorQuinto,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Puntuación con badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 1 : 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.colorPrimero.withValues(alpha: 0.3) : AppThemes.colorPrimero.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${jugador.puntuacion}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: ResponsiveApp.scaleText(11),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppThemes.colorPrimero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ListHistorialGeneral extends StatefulWidget {
  const _ListHistorialGeneral({super.key, required this.historiales, required this.historialController});

  final List<_HistorialConJugador> historiales;
  final ScrollController historialController;

  @override
  State<_ListHistorialGeneral> createState() => _ListHistorialGeneralState();
}

class _ListHistorialGeneralState extends State<_ListHistorialGeneral> with SlideUpAutoScrollMixin {
  @override
  void initState() {
    super.initState();
    // Programar scroll inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.historiales.isNotEmpty) {
        final effectiveController = getEffectiveController(context, widget.historialController);
        scheduleScrollToBottom(context, effectiveController);
      }
    });
  }

  @override
  void dispose() {
    cancelPendingScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveController = getEffectiveController(context, widget.historialController);

    if (widget.historiales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.colorPrimero.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.clockRotateLeft,
                size: 24,
                color: AppThemes.colorPrimero.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.noRecords,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(12),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: effectiveController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      separatorBuilder: (_, __) => Divider(
        color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.2),
        height: 1,
      ),
      itemCount: widget.historiales.length,
      itemBuilder: (context, index) {
        final item = widget.historiales[index];
        return _HistorialGeneralItem(
          key: ValueKey('hist-general-${item.historial.id ?? index}'),
          historial: item.historial,
          jugador: item.jugador,
          index: index,
        );
      },
    );
  }
}

class _HistorialGeneralItem extends StatefulWidget {
  const _HistorialGeneralItem({
    super.key,
    required this.historial,
    required this.jugador,
    required this.index,
  });

  final HistorialJugada historial;
  final Jugador jugador;
  final int index;

  @override
  State<_HistorialGeneralItem> createState() => _HistorialGeneralItemState();
}

class _HistorialGeneralItemState extends State<_HistorialGeneralItem> {
  late SwipeActionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwipeActionController();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final isAumentar = widget.historial.tipo == 'aumentar';
    final color = isAumentar ? const Color(0xFF4CAF50) : Colors.red[400]!;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final avatarSize = isSmallScreen ? 26.0 : 32.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SwipeActionCell(
        key: ValueKey(widget.historial.id),
        index: widget.index,
        controller: _controller,
        backgroundColor: Colors.transparent,
        trailingActions: [
          SwipeAction(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            title: AppLocalizations.of(context)!.delete,
            style: TextStyle(fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(11), color: Colors.white),
            onTap: (handler) => _deleteHistorial(context, handler),
            color: Colors.red[400]!,
          ),
        ],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: () => _controller.openCellAt(index: widget.index, trailing: true),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 10),
              child: Row(
                children: [
                  // Avatar del jugador
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.jugador.nombre != null && widget.jugador.nombre!.isNotEmpty ? widget.jugador.nombre![0].toUpperCase() : '?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ResponsiveApp.scaleText(12),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  // Nombre
                  Expanded(
                    child: Text(
                      widget.jugador.nombre!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ResponsiveApp.scaleText(13),
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : AppThemes.colorQuinto,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Puntuación
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAumentar ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 14,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${isAumentar ? '+' : '-'}${widget.historial.puntuacion}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: ResponsiveApp.scaleText(13),
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
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

  void _deleteHistorial(BuildContext context, CompletionHandler handler) {
    final l10n = AppLocalizations.of(context)!;
    CustomAlertDialog.show(
      context,
      title: l10n.confirm,
      menssage: l10n.confirmDeleteScore(widget.historial.puntuacion!.toInt(), widget.jugador.nombre!),
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
            final jugadorProvider = context.read<JugadorProvider>();
            final partidaProvider = context.read<PartidaProvider>();

            final Jugador? jugadorAnterior = jugadorProvider.jugadorEnTurno;
            jugadorProvider.changeJugadorEnTurno(widget.jugador);

            await jugadorProvider.deleteHistorial(historial: widget.historial);
            partidaProvider.refresh();

            if (jugadorAnterior != null) {
              jugadorProvider.changeJugadorEnTurno(jugadorAnterior);
            }
          }
        }),
      ],
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
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
      ),
    );
  }
}

class _KeyboardSection extends StatelessWidget {
  const _KeyboardSection({
    super.key,
    required this.puntuacionController,
    this.errorText,
    required this.onType,
  });

  final TextEditingController puntuacionController;
  final String? errorText;
  final VoidCallback onType;

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
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
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
              fontSize: ResponsiveApp.scaleText(14),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppThemes.colorQuinto,
            ),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.scoreLabel,
              fillColor: AppThemes.inputDisabledColor,
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isSmallScreen ? 2 : 4),
              labelStyle: TextStyle(
                color: errorText != null ? Colors.red[400] : AppThemes.labelInputDisabledColor,
                fontFamily: 'Poppins',
              ),
              floatingLabelStyle: TextStyle(
                color: errorText != null ? Colors.red[400] : (isDark ? Colors.grey[400] : AppThemes.colorQuinto),
                fontSize: ResponsiveApp.scaleText(15),
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: errorText != null ? Colors.red[400]! : Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: errorText != null ? Colors.red[400]! : Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: errorText != null ? Colors.red[400]! : Colors.transparent),
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
                    child: Text(
                      errorText!,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontFamily: 'Poppins',
                        fontSize: ResponsiveApp.scaleText(11),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Teclado
          CustomKeyboard(onChanged: (value) => changePuntuacionValue(value), tipo: KeyboardType.number),
        ],
      ),
    );
  }
}
