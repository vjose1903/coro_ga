// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class PartidaProvider extends ChangeNotifier {
  bool firstSearch = false;

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

  FormGroup formPartida = fb.group({
    'nombre': ['', Validators.required]
  });

  void navigateToPartida({required Partida partida, required BuildContext context}) {
    partidaEnTurno = partida;
    Navigator.pushNamed(context, 'partida');
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void changePartidaEnTurno(Partida partida) {
    partidaEnTurno = partida;
    notifyListeners();
  }

  void removeJugador(Jugador jugador) {
    int index = partidaEnTurno!.jugadores!.indexWhere((item) => item.id == jugador.id);
    partidaEnTurno!.jugadores!.removeAt(index);

    if (partidaEnTurno != null) {
      int indexPartida = partidas.indexWhere((item) => item.id == partidaEnTurno!.id);
      partidas[indexPartida] = partidaEnTurno!;
    }
    notifyListeners();
  }

  Future<SqlResponse> newPartida(Partida partida, BuildContext context) async {
    final response = await Partida.createPartida(context, partida: partida);
    Partida newPartida = response.data;

    partidas.add(newPartida);
    notifyListeners();

    return response;
  }

  Future<Partida> addJugadorToPartida(BuildContext context, {required Partida partida, required Jugador jugador}) async {
    final response = await Partida.addNewJugador(context, partida: partida, jugador: jugador);

    int index = partidas.indexWhere((item) => item.id == partida.id);
    partidas[index] = response.data;
    

    notifyListeners();

    return response.data;
  }

  getPartidas(BuildContext context, {required bool isLoading}) async {
    await Future.delayed(const Duration(microseconds: 100));

    final partidasFuture = Partida.getPartidas(context, isLoading: isLoading);

    partidas = await partidasFuture;
    firstSearch = true;
    notifyListeners();
    return partidasFuture;
  }

  Future<SqlResponse> deletePartida(BuildContext context, {required Partida partida, required CompletionHandler handler}) async {
    final response = await Partida.delete(context, partida: partida, isLoading: true);

    if (!response.hasError!) {
      await handler(true);

      partidas.remove(partida);
      notifyListeners();
      return response;
    } else {
      Fun.toast(type: ToasType.error, context: context, message: response.messages!.first);
      await handler(false);
      return response;
    }
  }

  Future<Partida?> getPartidaById(int? id, BuildContext context) async {
    late Partida? partida;

    if (id == null) {
      partida = Partida(nombre: '', jugadores: [Jugador(nombre: '', historialJugadas: []), Jugador(nombre: '', historialJugadas: [])]);
    } else {
      partida = await Partida.getPartidaById(id, context: context, isLoading: false);
    }

    return partida;
  }

  Future<SqlResponse> editPartida(BuildContext context, {required Partida partida, required String newNombrePartida}) async {
    final responseFuture = Partida.edit(context, partida: partida, newNombrePartida: newNombrePartida);
    final response = await responseFuture;

    if (!response.hasError!) {
      notifyListeners();
      return responseFuture;
    } else {
      Fun.toast(type: ToasType.error, context: context, message: response.messages!.first);
      return responseFuture;
    }
  }
}
