import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class CustomEstadoPartida extends StatelessWidget {
  const CustomEstadoPartida({Key? key, required}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartidasProvider partidaProvider = context.watch<PartidasProvider>();
    final partida = partidaProvider.partidaEnTurno!;

    Map<String, dynamic> estadoPartida = {
      "empate": {"label": "Empate", "icono": Icons.swap_horiz_outlined, "backgroundColor": Colors.yellow[300]},
      "sinIniciar": {"label": "Iniciando", "icono": Icons.arrow_forward, "backgroundColor": Colors.blue[300]},
    };

    String partidaIs = partida.isSinIniciar ? "sinIniciar" : "empate";

    if (partida.isSinIniciar || partida.isEmpate) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Container(
          decoration: getDecoration(estadoPartida[partidaIs]["backgroundColor"]),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(estadoPartida[partidaIs]["icono"], color: Colors.black.withOpacity(0.8)),
                const SizedBox(width: 10),
                Text(
                  estadoPartida[partidaIs]["label"],
                  style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                )
              ],
            ),
          ),
        ),
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
    Map ganadorPerdedor = getGanadorPerdedorMap(partida);
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: 60,
      child: ListView.separated(
          separatorBuilder: (_, __) => const SizedBox(width: 20),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: ganadorPerdedor.length,
          itemBuilder: (context, index) {
            List<String> estados = [Estado.ganador, Estado.perdedor];

            return Container(
              width: screenSize.width * 0.4,
              decoration: getDecoration(ganadorPerdedor[estados[index]]["backgroundColor"]),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(ganadorPerdedor[estados[index]]["icono"], color: Colors.black.withOpacity(0.8)),
                    const SizedBox(width: 10),
                    Flexible(
                        child: Text(
                      ganadorPerdedor[estados[index]]["label"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                    ))
                  ],
                ),
              ),
            );
          }),
    );
  }
}

BoxDecoration getDecoration(Color backgroundColor) {
  return BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [BoxShadow(blurRadius: 5, spreadRadius: -1, offset: Offset(0, 5), color: AppThemes.colorCuarto.withOpacity(0.3))],
  );
}

Map getGanadorPerdedorMap(Partida partida) {
  return {
    Estado.ganador: {
      "label": partida.getGandorOrPerdedor(tipo: Estado.ganador),
      "icono": Icons.arrow_upward,
      "backgroundColor": Colors.green[300],
    },
    Estado.perdedor: {
      "label": partida.getGandorOrPerdedor(tipo: Estado.perdedor),
      "icono": Icons.arrow_downward,
      "backgroundColor": Colors.red[300],
    }
  };
}
