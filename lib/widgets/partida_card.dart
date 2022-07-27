import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';

class PartidaCard extends StatelessWidget {
  const PartidaCard({
    Key? key,
    required this.partida,
    required this.functionBorrar,
    required this.functionEditar,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Partida partida;
  final Function functionBorrar;
  final Function functionEditar;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: AppThemes.themeColor_2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: AppThemes.colorSegundo.withOpacity(0.3),
      elevation: 7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SwipeActionCell(
          backgroundColor: Colors.transparent,
          key: UniqueKey(),
          trailingActions: <SwipeAction>[
            SwipeAction(
                nestedAction: SwipeNestedAction(title: "Confirmar"),
                title: "Borrar",
                onTap: (CompletionHandler handler) async {
                  functionBorrar(handler);
                },
                color: Colors.red),
            SwipeAction(
                title: "Editar",
                onTap: (CompletionHandler handler) async {
                  functionEditar();
                  await handler(false);
                },
                color: Colors.grey)
          ],
          child: InkWell(
            onTap: () => onTap(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width - 160),
                        child: Text(
                          partida.nombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppThemes.colorSegundo),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          LabelWithIcon(icon: FontAwesomeIcons.users, label: "${partida.cantJugadores}"),
                          const SizedBox(width: 30),
                          EstadoPartida(partida: partida)
                        ],
                      )
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EstadoPartida extends StatelessWidget {
  const EstadoPartida({Key? key, required this.partida}) : super(key: key);

  final Partida partida;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Map<String, dynamic> estadoPartida = {
      "empate": {"label": "Empate", "icono": Icons.swap_horiz_outlined, "iconColor": Colors.yellow[800], "color": Colors.yellow[100]},
      "sinIniciar": {"label": "Iniciando", "icono": Icons.arrow_forward, "iconColor": Colors.blue[800], "color": Colors.blue[100]},
    };
    String partidaIs = partida.isSinIniciar ? "sinIniciar" : "empate";

    if (partida.isSinIniciar || partida.isEmpate) {
      return LabelWithIcon(
          orden: Orden.primeroIcono,
          maxSize: size.width - 335,
          icon: estadoPartida[partidaIs]["icono"],
          label: estadoPartida[partidaIs]["label"],
          iconColor: estadoPartida[partidaIs]["iconColor"],
          iconBackgroundColor: estadoPartida[partidaIs]["color"]);
    } else {
      return _GanadorPerdedor(partida: partida);
    }
  }
}

class _GanadorPerdedor extends StatelessWidget {
  const _GanadorPerdedor({Key? key, required this.partida}) : super(key: key);
  final Partida partida;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        //
        LabelWithIcon(
            orden: Orden.primeroIcono,
            maxSize: size.width - 335,
            icon: Icons.arrow_upward,
            label: partida.getGandorOrPerdedor(tipo: Estado.ganador),
            iconColor: Colors.green[500],
            iconBackgroundColor: const Color(0xFFDDF2DE)),
        //
        const SizedBox(width: 10),
        //
        LabelWithIcon(
            orden: Orden.primeroIcono,
            maxSize: size.width - 335,
            icon: Icons.arrow_downward,
            label: partida.getGandorOrPerdedor(tipo: Estado.perdedor),
            iconColor: Colors.red[300],
            iconBackgroundColor: const Color(0xFFF2DDDD)),
      ],
    );
  }
}
