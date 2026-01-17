import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_score/l10n/app_localizations.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/screens/ganador.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/widgets/layout.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class HistorialGeneral extends StatefulWidget {
  const HistorialGeneral({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  State<HistorialGeneral> createState() => _HistorialGeneralState();
}

class _HistorialGeneralState extends State<HistorialGeneral> {
  final TextEditingController puntuacionController = TextEditingController();
  final ScrollController historialController = ScrollController();
  Jugador? jugadorSeleccionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (historialController.hasClients) {
        historialController.jumpTo(historialController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
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
    List<_HistorialConJugador> todosHistoriales = [];
    for (var jugador in jugadores) {
      if (jugador.historialJugadas != null) {
        for (var historial in jugador.historialJugadas!) {
          todosHistoriales.add(_HistorialConJugador(jugador: jugador, historial: historial));
        }
      }
    }
    todosHistoriales.sort((a, b) => a.historial.id!.compareTo(b.historial.id!));

    return Column(
      children: [
        // Header
        _HistorialHeader(cantRegistros: todosHistoriales.length),
        const SizedBox(height: 16),

        // Selector de jugador
        _JugadorSelector(
          jugadores: jugadores,
          jugadorSeleccionado: jugadorSeleccionado,
          onChanged: (jugador) => setState(() => jugadorSeleccionado = jugador),
        ),
        const SizedBox(height: 12),

        // Lista de historial
        Expanded(
          flex: 2,
          child: Container(
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
        const SizedBox(height: 12),

        // Teclado y campo de puntuación
        if (partida.tipo == "Puntuación") ...[
          _KeyboardSection(puntuacionController: puntuacionController),
          const SizedBox(height: 12),
        ],

        // Botones de acción
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Row(
              children: [
                Expanded(
                  child: _ActionScoreButton(
                    icon: Icons.add_rounded,
                    label: l10n.increase,
                    color: const Color(0xFF4CAF50),
                    onTap: () => _changePuntuacion(
                      context: context,
                      jugadorProvider: jugadorProvider,
                      partidaProvider: partidaProvider,
                      tipo: "aumentar",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionScoreButton(
                    icon: Icons.remove_rounded,
                    label: l10n.decrease,
                    color: Colors.red[400]!,
                    onTap: () => _changePuntuacion(
                      context: context,
                      jugadorProvider: jugadorProvider,
                      partidaProvider: partidaProvider,
                      tipo: "reducir",
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _changePuntuacion({
    required BuildContext context,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required String tipo,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    
    if (jugadorSeleccionado == null) {
      Toast.show(type: ToastType.warning, context: context, message: l10n.selectPlayer);
      return;
    }

    String puntuacion = partidaProvider.partidaEnTurno!.tipo == "Puntuación" ? puntuacionController.text : "1";

    if (puntuacion.isEmpty || puntuacion == "0") {
      String msg = puntuacion == "0" ? l10n.scoreMustBeGreaterThanZero : l10n.enterScoreToContinue;
      Toast.show(type: ToastType.warning, context: context, title: l10n.warning, message: msg);
      return;
    }

    int puntuacionInt = int.parse(puntuacion);
    int puntuacionActual = jugadorSeleccionado!.puntuacion!;

    if (tipo == "reducir" && puntuacionActual - puntuacionInt < 0) {
      String msgError = partidaProvider.partidaEnTurno!.tipo == "Puntuación"
          ? l10n.minScoreWarning
          : l10n.minRoundWarning;
      Toast.show(type: ToastType.warning, context: context, title: l10n.warning, message: msgError);
      return;
    }

    MyLoading.show();

    // Cambiar temporalmente el jugador en turno para usar el método existente
    Jugador? jugadorAnterior = jugadorProvider.jugadorEnTurno;
    jugadorProvider.changeJugadorEnTurno(jugadorSeleccionado!);

    SqlResponse response = await jugadorProvider.changePuntuacion(
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
      puntuacionController.text = "";
      setState(() {}); // Refrescar la lista

      int newPuntuacion = response.data.puntuacion;
      if (newPuntuacion >= partidaProvider.partidaEnTurno!.maxPuntuacion!.toInt()) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            settings: RouteSettings(arguments: {
              "partida": partidaProvider.partidaEnTurno!.nombre,
              "jugador": jugadorSeleccionado!.nombre,
            }),
            pageBuilder: (context, animation, secondaryAnimation) => const GanadorScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }

      // Scroll al final
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (historialController.hasClients) {
          historialController.animateTo(
            historialController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }
}

class _HistorialConJugador {
  final Jugador jugador;
  final HistorialJugada historial;

  _HistorialConJugador({required this.jugador, required this.historial});
}

// ============================================
// WIDGETS PRIVADOS
// ============================================

class _HistorialHeader extends StatelessWidget {
  const _HistorialHeader({required this.cantRegistros});

  final int cantRegistros;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
              : [AppThemes.colorPrimero.withValues(alpha: 0.08), AppThemes.colorPrimero.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppThemes.colorPrimero.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
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
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.generalHistory,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppThemes.colorQuinto,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.records(cantRegistros),
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectedPlayer,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppThemes.inputColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButton<Jugador>(
            value: jugadorSeleccionado,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppThemes.themeColor_1 : Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            items: jugadores.map((jugador) {
              return DropdownMenuItem<Jugador>(
                value: jugador,
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          jugador.nombre != null && jugador.nombre!.isNotEmpty
                              ? jugador.nombre![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Nombre
                    Expanded(
                      child: Text(
                        jugador.nombre!,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: isDark ? Colors.white : AppThemes.colorQuinto,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Puntuación con badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppThemes.colorPrimero.withValues(alpha: 0.3)
                            : AppThemes.colorPrimero.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${jugador.puntuacion}",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
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
        ),
      ],
    );
  }
}

class _ListHistorialGeneral extends StatelessWidget {
  const _ListHistorialGeneral({Key? key, required this.historiales, required this.historialController}) : super(key: key);

  final List<_HistorialConJugador> historiales;
  final ScrollController historialController;

  @override
  Widget build(BuildContext context) {
    // Usar el scrollController del SlideUp si está disponible
    final slideUpController = SlideUpScrollController.of(context);
    final effectiveController = slideUpController ?? historialController;
    
    if (historiales.isEmpty) {
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
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[500]),
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
      itemCount: historiales.length,
      itemBuilder: (context, index) {
        final item = historiales[index];
        return _HistorialGeneralItem(
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
    final isAumentar = widget.historial.tipo == "aumentar";
    final color = isAumentar ? const Color(0xFF4CAF50) : Colors.red[400]!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SwipeActionCell(
        key: ValueKey(widget.historial.id),
        index: widget.index,
        controller: _controller,
        backgroundColor: Colors.transparent,
        trailingActions: [
          SwipeAction(
            content: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const FaIcon(FontAwesomeIcons.trash, color: Colors.white, size: 18),
            ),
            onTap: (handler) => _deleteHistorial(context, handler),
            color: Colors.transparent,
          ),
        ],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: () => _controller.openCellAt(index: widget.index, trailing: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  // Avatar del jugador
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.colorPrimero, AppThemes.colorTercero],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.jugador.nombre != null && widget.jugador.nombre!.isNotEmpty
                            ? widget.jugador.nombre![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nombre
                  Expanded(
                    child: Text(
                      widget.jugador.nombre!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
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
                            fontSize: 13,
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
      menssage: l10n.confirmDeleteScore(widget.historial.puntuacion!, widget.jugador.nombre!),
      dialogType: DialogType.error,
      buttonsList: [
        CustomActionsButtons.cancelButton({
          "onTap": () {
            Navigator.pop(context);
            handler(false);
          }
        }),
        CustomActionsButtons.aceptarButton({
          "onTap": () async {
            Navigator.pop(context);
            final jugadorProvider = context.read<JugadorProvider>();
            final partidaProvider = context.read<PartidaProvider>();

            Jugador? jugadorAnterior = jugadorProvider.jugadorEnTurno;
            jugadorProvider.changeJugadorEnTurno(widget.jugador);

            await jugadorProvider.deleteHistorial(historial: widget.historial);
            partidaProvider.refresh();

            if (jugadorAnterior != null) {
              jugadorProvider.changeJugadorEnTurno(jugadorAnterior);
            }

            await handler(true);
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
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

class _KeyboardSection extends StatelessWidget {
  const _KeyboardSection({Key? key, required this.puntuacionController}) : super(key: key);

  final TextEditingController puntuacionController;

  void changePuntuacionValue(String value) {
    if (value != "DEL") {
      if (puntuacionController.text == "0" && value == "0") return;
      if (puntuacionController.text == "0" && value != "0") {
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
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
          width: 1,
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
        children: [
          // Input de puntuación
          TextField(
            controller: puntuacionController,
            enabled: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppThemes.colorQuinto,
            ),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.scoreLabel,
              fillColor: AppThemes.inputDisabledColor,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              labelStyle: TextStyle(
                color: AppThemes.labelInputDisabledColor, 
                fontFamily: 'Poppins',
              ),
              floatingLabelStyle: TextStyle(
                color: isDark ? Colors.grey[400] : AppThemes.colorQuinto,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              border: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Teclado
          CustomKeyboard(onChanged: (value) => changePuntuacionValue(value), tipo: KeyboardType.number),
        ],
      ),
    );
  }
}

