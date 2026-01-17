import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/screens/ganador.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/widgets/layout.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class PuntuacionForm extends StatelessWidget {
  const PuntuacionForm({Key? key, required this.panelController}) : super(key: key);
  final PanelController panelController;
  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return index == 0
              ? PuntuacionPage(panelController: panelController, pageController: pageController)
              : EditarEntidad(pageController: pageController);
        });
  }
}

class PuntuacionPage extends StatefulWidget {
  const PuntuacionPage({Key? key, required this.panelController, required this.pageController}) : super(key: key);
  final PanelController panelController;
  final PageController pageController;

  @override
  State<PuntuacionPage> createState() => _PuntuacionPageState();
}

class _PuntuacionPageState extends State<PuntuacionPage> {
  // El widget GoogleBannerAd maneja su propio dispose internamente
  final GoogleBannerAd anuncio = const GoogleBannerAd(location: AdLocation.puntuacion);
  final ScrollController historialController = ScrollController();
  int? _lastJugadorId;

  @override
  void dispose() {
    historialController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (historialController.hasClients && historialController.position.maxScrollExtent > 0) {
        historialController.animateTo(
          historialController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController puntuacionController = TextEditingController();

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
        final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();

        // Scroll al final cuando cambia el jugador
        if (_lastJugadorId != jugadorProvider.jugadorEnTurno?.id) {
          _lastJugadorId = jugadorProvider.jugadorEnTurno?.id;
          _scrollToBottom();
        }

        return Column(
          children: [
            // Header del jugador
            _JugadorHeader(
              nombre: jugadorProvider.nombreJugador,
              puntuacion: jugadorProvider.jugadorEnTurno?.puntuacion ?? 0,
              canDelete: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
              onEdit: () {
                jugadorProvider.jugadorEditar = jugadorProvider.jugadorEnTurno;
                jugadorProvider.formJugador.patchValue(jugadorProvider.jugadorEnTurno!.toMap());
                nextPage();
              },
              onDelete: () {
                Jugador jugador = jugadorProvider.jugadorEnTurno!;
                jugadorProvider.deleteJugador(context, jugador: jugador, panelController: widget.panelController, callBack: (value) {});
              },
            ),
            const SizedBox(height: 12),

            // Historial
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemes.themeColor_1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Preferences.isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.colorCuarto.withValues(alpha: Preferences.isDarkMode ? 0.15 : 0.08),
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
            // TECLADO CON INPUT
            if (partidaProvider.partidaEnTurno!.tipo == "Puntuación") _KeyboardSection(puntuacionController: puntuacionController),
            if (partidaProvider.partidaEnTurno!.tipo == "Puntuación") const SizedBox(height: 10),
            Row(
              children: [
                // AUMENTAR
                Expanded(
                  child: _ActionScoreButton(
                    icon: Icons.add_rounded,
                    label: "Aumentar",
                    color: Colors.green,
                    onTap: () {
                      String puntuacion = partidaProvider.partidaEnTurno!.tipo == "Puntuación" ? puntuacionController.text : "1";
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (historialController.hasClients) {
                              historialController.animateTo(historialController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
                            }
                          });
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // REDUCIR
                Expanded(
                  child: _ActionScoreButton(
                    icon: Icons.remove_rounded,
                    label: "Reducir",
                    color: Colors.red[400]!,
                    onTap: () {
                      String puntuacion = partidaProvider.partidaEnTurno!.tipo == "Puntuación" ? puntuacionController.text : "1";
                      changePuntuacion(jugadorProvider: jugadorProvider, puntuacion: puntuacion, tipo: "reducir", context: context)
                          .then((value) => puntuacionController.text = "");
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ANUNCIOS ==========================================
            anuncio
          ],
        );
      },
    );
  }

  nextPage() {
    widget.pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  Future<int> changePuntuacion(
      {required String puntuacion, required String tipo, required JugadorProvider jugadorProvider, required BuildContext context}) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    if (puntuacion.isNotEmpty && puntuacion != "0") {
      int puntuacionInt = int.parse(puntuacion);

      Jugador jugador = jugadorProvider.jugadorEnTurno!;
      int puntuacion_actual = jugador.puntuacion!;

      if (tipo == "reducir" && puntuacion_actual - puntuacionInt < 0) {
        String msgErrorReducir =
            partidaProvider.partidaEnTurno!.tipo == "Puntuación" ? "La puntuación minima debe de ser 0." : "La ronda minima debe de ser 0.";
        Toast.show(type: ToastType.warning, context: context, title: "AVISO", message: msgErrorReducir);

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
      String msg = puntuacion == "0" ? "Puntuación debe de ser mayor a 0" : "Debe introducir una puntutación para continuar";

      Toast.show(type: ToastType.warning, context: context, title: "AVISO", message: msg);
      return 0;
    }
  }
}

class _ListHistorial extends StatelessWidget {
  const _ListHistorial({Key? key, required this.historialController}) : super(key: key);
  final ScrollController historialController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider? partidaProvider = context.read<PartidaProvider?>();
    final JugadorProvider? jugadorProvider = context.watch<JugadorProvider?>();
    final Jugador? jugador = jugadorProvider?.jugadorEnTurno;
    final msgNoRgistros = partidaProvider!.partidaEnTurno!.tipo == "Puntuación" ? "No hay puntuaciones registradas" : "No tiene rondas registradas";

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

    // Usar el scrollController del SlideUp si está disponible
    final slideUpController = SlideUpScrollController.of(context);
    final effectiveController = slideUpController ?? historialController;
    
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: effectiveController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            separatorBuilder: (_, __) => Divider(
              color: Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.2),
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
            title: "Borrar",
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11),
            onTap: (CompletionHandler handler) async {
            CustomAlertDialog.show(
              context,
              title: "Confirmar",
              menssage: "¿Seguro que desea eliminar la puntuación ${widget.historial.puntuacion} del jugador ${widget.jugadorNombre}?",
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
                  widget.historial.tipo!.capitalize(),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppThemes.colorQuinto,
            ),
            decoration: InputDecoration(
              labelText: 'Puntuación',
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

// Widget para el header del jugador
class _JugadorHeader extends StatelessWidget {
  final String nombre;
  final int puntuacion;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JugadorHeader({
    required this.nombre,
    required this.puntuacion,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

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
                  'Puntuación: $puntuacion',
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
                : (Preferences.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
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
