import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class FormPartidaProvider extends ChangeNotifier {
  Partida? partida;

  get jugadores {
    return partida != null ? partida!.jugadores : [];
  }

  Future getPartida(int? id, BuildContext context) async {
    final formPartidaProvider = Provider.of<PartidaProvider>(context, listen: false);

    final Future<Partida?> partidaFuture = formPartidaProvider.getPartidaById(id, context);
    partida = await partidaFuture;

    notifyListeners();
    return partidaFuture;
  }

  void addJugadorToList(Jugador jugador) {
    if (partida == null) return;

    partida!.jugadores!.add(jugador);
    notifyListeners();
  }

  void removeJugadorToList(Jugador jugador) {
    if (partida == null) return;
    partida!.jugadores!.remove(jugador);

    notifyListeners();
  }
}
