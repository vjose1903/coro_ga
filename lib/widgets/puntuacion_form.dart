import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/ganador.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import 'widgets.dart';
import 'slide_up_header.dart';

class PuntuacionForm extends StatelessWidget {
  const PuntuacionForm({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return PuntuacionPage(panelController: panelController);
  }
}

class PuntuacionPage extends StatefulWidget {
  const PuntuacionPage({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;

  @override
  State<PuntuacionPage> createState() => _PuntuacionPageState();
}

class _PuntuacionPageState extends State<PuntuacionPage> with SlideUpAutoScrollMixin {
  // El widget GoogleBannerAd maneja su propio dispose internamente
  final GoogleBannerAd anuncio = const GoogleBannerAd(location: AdLocation.puntuacion);
  final ScrollController historialController = ScrollController();
  final TextEditingController puntuacionController = TextEditingController();

  @override
  void dispose() {
    cancelPendingScroll();
    historialController.dispose();
    puntuacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final bool hasTeclado = partidaProvider.partidaEnTurno!.tipo == "Puntuación";
    final isDark = Preferences.isDarkMode;

    // Usar ClipRect para evitar overflow visual cuando el panel se reduce
    return ClipRect(
      child: Column(
        children: [
          // Header del jugador - FIJO arriba
          _JugadorHeader(
            nombre: jugadorProvider.nombreJugador,
            puntuacion: jugadorProvider.jugadorEnTurno?.puntuacion ?? 0,
            canDelete: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
            panelController: widget.panelController,
            onEdit: () {
              jugadorProvider.jugadorEditar = jugadorProvider.jugadorEnTurno;
              jugadorProvider.formJugador.patchValue(jugadorProvider.jugadorEnTurno!.toMap());
              _showEditarJugadorModal(context);
            },
            onDelete: () {
              Jugador jugador = jugadorProvider.jugadorEnTurno!;
              jugadorProvider.deleteJugador(context, jugador: jugador, panelController: widget.panelController, callBack: (value) {});
            },
          ),
          const SizedBox(height: 12),

          // Historial - Expanded para ocupar espacio restante
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppThemes.themeColor_1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppThemes.colorCuarto.withValues(alpha: isDark ? 0.15 : 0.08),
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
          ),
          const SizedBox(height: 12),
          // TECLADO CON INPUT - FIJO
          if (hasTeclado) _KeyboardSection(puntuacionController: puntuacionController),
          if (hasTeclado) const SizedBox(height: 15),
          // BOTONES - FIJOS abajo
          Row(
            children: [
              // REDUCIR
              Expanded(
                child: _ActionScoreButton(
                  icon: Icons.remove_rounded,
                  label: AppLocalizations.of(context)!.decrease,
                  color: Colors.red[400]!,
                  onTap: () {
                    final scrollController = getEffectiveController(context, historialController);
                    String puntuacion = hasTeclado ? puntuacionController.text : "1";

                    changePuntuacion(jugadorProvider: jugadorProvider, puntuacion: puntuacion, tipo: "reducir", context: context)
                        .then((newPuntuacion) {
                      if (newPuntuacion != 0) {
                        puntuacionController.text = "";
                        scheduleScrollToBottom(context, scrollController);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // AUMENTAR
              Expanded(
                child: _ActionScoreButton(
                  icon: Icons.add_rounded,
                  label: AppLocalizations.of(context)!.increase,
                  color: Colors.green,
                  onTap: () {
                    final scrollController = getEffectiveController(context, historialController);
                    String puntuacion = hasTeclado ? puntuacionController.text : "1";
                    changePuntuacion(jugadorProvider: jugadorProvider, puntuacion: puntuacion, tipo: "aumentar", context: context)
                        .then((newPuntuacion) {
                      if (newPuntuacion != 0) {
                        puntuacionController.text = "";
                        if (newPuntuacion >= partidaProvider.partidaEnTurno!.maxPuntuacion!.toInt()) {
                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                  settings: RouteSettings(arguments: {
                                    "partida": partidaProvider.partidaEnTurno!.nombre,
                                    "jugador": jugadorProvider.jugadorEnTurno!.nombre,
                                  }),
                                  pageBuilder: (context, animation, secondaryAnimation) => const GanadorScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                      FadeTransition(opacity: animation, child: child),
                                  transitionDuration: const Duration(milliseconds: 400)));
                        }
                        scheduleScrollToBottom(context, scrollController);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // ANUNCIOS - FIJO abajo
          anuncio
        ],
      ),
    );
  }

  void _showEditarJugadorModal(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final slideUpProvider = context.read<SlideUpProvider>();

    // Cerrar el slideUp cuando se abre el modal (sin limpiar jugadorEditar)
    slideUpProvider.closeSlideUp(controller: widget.panelController, skipClean: true);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppThemes.themeColor_2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          height: screenHeight * 0.5,
          padding: const EdgeInsets.all(16),
          child: EditarEntidad(
            onClose: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    ).then((_) {
      // Esperar al siguiente frame para asegurar que los datos estén sincronizados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        slideUpProvider.openSlideUp(
          controller: widget.panelController,
          bodyContent: PuntuacionForm(panelController: widget.panelController),
        );
      });
    });
  }

  Future<int> changePuntuacion(
      {required String puntuacion, required String tipo, required JugadorProvider jugadorProvider, required BuildContext context}) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    if (puntuacion.isNotEmpty && puntuacion != "0") {
      int puntuacionInt = int.parse(puntuacion);

      Jugador jugador = jugadorProvider.jugadorEnTurno!;
      int puntuacion_actual = jugador.puntuacion!;

      if (tipo == "reducir" && puntuacion_actual - puntuacionInt < 0) {
        final l10n = AppLocalizations.of(context)!;
        String msgErrorReducir = partidaProvider.partidaEnTurno!.tipo == "Puntuación" ? l10n.minScoreWarning : l10n.minRoundWarning;
        Toast.show(type: ToastType.warning, context: context, title: l10n.warning, message: msgErrorReducir);

        return puntuacion_actual;
      } else {
        MyLoading.show();
        SqlResponse response = await jugadorProvider.changePuntuacion(jugador: jugador, newPuntuacion: puntuacionInt, tipo: tipo);
        partidaProvider.refresh();
        jugadorProvider.changeJugadorEnTurno(response.data);
        MyLoading.close();
        return response.data.puntuacion;
      }
    } else {
      final l10n = AppLocalizations.of(context)!;
      String msg = puntuacion == "0" ? l10n.scoreMustBeGreaterThanZero : l10n.enterScoreToContinue;

      Toast.show(type: ToastType.warning, context: context, title: l10n.warning, message: msg);
      return 0;
    }
  }
}

class _ListHistorial extends StatefulWidget {
  const _ListHistorial({Key? key, required this.historialController}) : super(key: key);
  final ScrollController historialController;

  @override
  State<_ListHistorial> createState() => _ListHistorialState();
}

class _ListHistorialState extends State<_ListHistorial> with SlideUpAutoScrollMixin {
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
    final jugadorProvider = context.read<JugadorProvider?>();
    final jugador = jugadorProvider?.jugadorEnTurno;
    if (jugador?.historialJugadas != null && jugador!.historialJugadas!.isNotEmpty) {
      _lastJugadorId = jugador.id;
      final effectiveController = getEffectiveController(context, widget.historialController);
      scheduleScrollToBottom(context, effectiveController);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveController = getEffectiveController(context, widget.historialController);
    final isDark = Preferences.isDarkMode;

    final PartidaProvider? partidaProvider = context.read<PartidaProvider?>();
    final JugadorProvider? jugadorProvider = context.watch<JugadorProvider?>();
    final Jugador? jugador = jugadorProvider?.jugadorEnTurno;
    final l10n = AppLocalizations.of(context)!;
    final msgNoRgistros = partidaProvider!.partidaEnTurno!.tipo == "Puntuación" ? l10n.noScoresRegistered : l10n.noRoundsRegistered;

    // Scroll cuando cambia el jugador (después de init)
    if (_lastJugadorId != null && _lastJugadorId != jugador?.id && jugador?.historialJugadas != null && jugador!.historialJugadas!.isNotEmpty) {
      _lastJugadorId = jugador.id;
      scheduleScrollToBottom(context, effectiveController);
    }

    if (jugador == null) return Container();

    if (jugador.historialJugadas != null && jugador.historialJugadas!.isEmpty) {
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
              child: Icon(Icons.history_rounded, size: 32, color: AppThemes.colorPrimero.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 12),
            Text(msgNoRgistros, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[500]))
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
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.2),
              height: 1,
            ),
            itemCount: jugador.historialJugadas!.length,
            itemBuilder: (context, index) {
              HistorialJugada historial = jugador.historialJugadas![index];
              return _HistorialItem(
                historial: historial,
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
  final HistorialJugada historial;
  final String jugadorNombre;
  final int index;

  const _HistorialItem({
    required this.historial,
    required this.jugadorNombre,
    required this.index,
  });

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
    final bool isAumentar = widget.historial.tipo == "aumentar";

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SwipeActionCell(
        key: ValueKey(widget.historial.id),
        backgroundColor: Colors.transparent,
        controller: _swipeController,
        index: widget.index,
        trailingActions: [
          SwipeAction(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            title: AppLocalizations.of(context)!.delete,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11),
            onTap: (CompletionHandler handler) async {
              final l10n = AppLocalizations.of(context)!;
              CustomAlertDialog.show(
                context,
                title: l10n.confirm,
                menssage: l10n.confirmDeleteScore(widget.historial.puntuacion!.toInt(), widget.jugadorNombre),
                dialogType: DialogType.error,
                buttonsList: [
                  CustomActionsButtons.cancelButton({
                    "label": l10n.cancel,
                    "onTap": () {
                      Navigator.pop(context);
                      handler(false);
                    }
                  }),
                  CustomActionsButtons.aceptarButton({
                    "label": l10n.accept,
                    "onTap": () async {
                      Navigator.pop(context);
                      final jugadorProvider = context.read<JugadorProvider>();
                      final partidaProvider = context.read<PartidaProvider>();
                      await jugadorProvider.deleteHistorial(historial: widget.historial);
                      partidaProvider.refresh();
                      await handler(true);
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
            onLongPress: () => _swipeController.openCellAt(index: widget.index, trailing: true),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (isAumentar ? Colors.green : Colors.red).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isAumentar ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: isAumentar ? Colors.green : Colors.red[400],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${isAumentar ? '+' : '-'}${widget.historial.puntuacion}",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isAumentar ? Colors.green : Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    L10n.getActionType(context, widget.historial.tipo),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey[500],
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppThemes.colorQuinto,
            ),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.scoreLabel,
              fillColor: AppThemes.inputDisabledColor,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

// Widget para el header del jugador
class _JugadorHeader extends StatelessWidget {
  final String nombre;
  final int puntuacion;
  final bool canDelete;
  final PanelController panelController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JugadorHeader({
    required this.nombre,
    required this.puntuacion,
    required this.canDelete,
    required this.panelController,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return SlideUpHeader(
      panelController: panelController,
      child: Row(
        children: [
          // Avatar con inicial
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemes.colorPrimero,
                  AppThemes.colorPrimero.withValues(alpha: 0.7),
                ],
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
            child: Center(
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppThemes.colorQuinto,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.playerScore(puntuacion),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Botones
          _MiniIconButton(
            icon: Icons.edit_outlined,
            onTap: onEdit,
          ),
          if (canDelete) ...[
            const SizedBox(width: 8),
            _MiniIconButton(
              icon: Icons.delete_outline_rounded,
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
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MiniIconButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

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
                : (Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red[400] : (Preferences.isDarkMode ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class _ActionScoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionScoreButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(14),
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
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
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
