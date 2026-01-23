// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class PartidaProvider extends ChangeNotifier {
  bool isFirstSearch = true;
  bool isChangePartida = false;

  List<Partida> partidas = [];
  Partida? partidaEnTurno;
  Partida? _partidaEditar;

  set partidaEditar(Partida? jugador) {
    _partidaEditar = jugador;
    notifyListeners();
  }

  Partida? get partidaEditar {
    return _partidaEditar;
  }

  void refresh() {
    notifyListeners();
  }

  void changePartidaEnTurno(Partida partida) {
    partidaEnTurno = partida;
    isChangePartida = true;
    notifyListeners();

    // Reset flag después de que el frame se haya renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isChangePartida = false;
    });
  }

  void removeJugador(Jugador jugador) {
    final int index = partidaEnTurno!.jugadores!.indexWhere((item) => item.id == jugador.id);
    partidaEnTurno!.jugadores!.removeAt(index);

    if (partidaEnTurno != null) {
      final int indexPartida = partidas.indexWhere((item) => item.id == partidaEnTurno!.id);
      partidas[indexPartida] = partidaEnTurno!;
    }
    notifyListeners();
  }

  Future<SqlResponse> newPartida(Partida partida, BuildContext context) async {
    final response = await Partida.createPartida(context, partida: partida);
    final Partida newPartida = response.data;

    partidas.add(newPartida);
    notifyListeners();

    return response;
  }

  Future<Partida> addJugadorToPartida(BuildContext context, {required Partida partida, required Jugador jugador}) async {
    final response = await Partida.addNewJugador(partida: partida, jugador: jugador);

    final int index = partidas.indexWhere((item) => item.id == partida.id);
    partidas[index] = response.data;

    // notifyListeners();

    return response.data;
  }

  getPartidas() async {
    MyLoading.show();

    partidas = await Partida.getPartidas();
    isFirstSearch = false;
    notifyListeners();
    MyLoading.close();
    return partidas;
  }

  Future<SqlResponse> deletePartida(BuildContext context, {required Partida partida, CompletionHandler? handler}) async {
    final response = await Partida.delete(partida: partida);

    if (!response.hasError!) {
      if (handler != null) await handler(true);

      partidas.remove(partida);
      notifyListeners();
      return response;
    } else {
      Toast.show(type: ToastType.error, context: context, message: response.messages!.first);
      if (handler != null) await handler(false);
      return response;
    }
  }

  Future<SqlResponse> editPartida(BuildContext context, {required Partida partida, required String newNombrePartida}) async {
    final responseFuture = Partida.edit(partida: partida, newNombrePartida: newNombrePartida);
    final response = await responseFuture;

    if (!response.hasError!) {
      notifyListeners();
      return responseFuture;
    } else {
      Toast.show(type: ToastType.error, context: context, message: response.messages!.first);
      return responseFuture;
    }
  }
}
