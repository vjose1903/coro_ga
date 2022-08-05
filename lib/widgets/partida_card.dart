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
      shadowColor: AppThemes.colorCuarto.withOpacity(0.3),
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partida.nombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: AppThemes.colorPrimero),
                        ),
                        Text(
                          partida.tipo!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: AppThemes.currentTheme == Themes.dark ? Colors.grey[600]!.withOpacity(0.4) : Colors.grey.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Text(partida.cantJugadores.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Poppins')),
                                    const IconRounded(icon: FontAwesomeIcons.users, marginLeft: 5)
                                  ],
                                )),
                            Flexible(flex: 8, child: EstadoPartida(partida: partida))

                            // Expanded(child: EstadoPartida(partida: partida))
                          ],
                        )
                      ],
                    ),
                  ),
                  const Flexible(flex: 1, child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18)),
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
      return Row(
        children: [
          IconRounded(
            icon: estadoPartida[partidaIs]["icono"],
            marginLeft: 5,
            backgroundColor: estadoPartida[partidaIs]["color"],
            iconColor: estadoPartida[partidaIs]["iconColor"],
            marginRight: 5,
          ),
          Text(estadoPartida[partidaIs]["label"],
              overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Poppins')),
        ],
      );
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
        Flexible(
            flex: 5,
            child: Row(
              children: [
                IconRounded(
                  icon: Icons.arrow_upward,
                  marginLeft: 5,
                  backgroundColor: const Color(0xFFDDF2DE),
                  iconColor: Colors.green[500]!,
                  marginRight: 5,
                ),
                Expanded(
                  child: Text(partida.getGandorOrPerdedor(tipo: Estado.ganador),
                      overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Poppins')),
                ),
              ],
            )),
        //
        const SizedBox(width: 10),
        //

        Flexible(
            flex: 5,
            child: Row(
              children: [
                IconRounded(
                  icon: Icons.arrow_downward,
                  marginLeft: 5,
                  backgroundColor: const Color(0xFFF2DDDD),
                  iconColor: Colors.red[300]!,
                  marginRight: 5,
                ),
                Expanded(
                  child: Text(partida.getGandorOrPerdedor(tipo: Estado.perdedor),
                      overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Poppins')),
                ),
              ],
            )),
      ],
    );
  }
}
