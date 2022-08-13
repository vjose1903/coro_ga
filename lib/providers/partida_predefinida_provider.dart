import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/utils/functions.dart';

import 'package:reactive_forms/reactive_forms.dart';

class PartidaPredefinidaProvider extends ChangeNotifier {
  List<PartidaPredefinida> partidasPredefinidas = [];
  PartidaPredefinida? partidaPredefinidaEditar;

  FormGroup form = fb.group({
    'nombre': ['', Validators.required],
    'tipo': ['', Validators.required],
    'maxPuntuacion': [1, Validators.min(1)],
    'cantidadJugadores': [2, Validators.min(2)],
    'orden': [null]
  });

  void changeTipo(value) {
    notifyListeners();
  }

  void changeCantidadJugadores({required String tipo, required BuildContext context}) {
    print("formPartidaPredefinida.control(cantidadJugadores).value: ${form.control("cantidadJugadores").value} ");
    int actualCantidad = form.control("cantidadJugadores").value;

    if (tipo == "+") {
      form.control("cantidadJugadores").value += 1;
    } else {
      if (actualCantidad > 2) {
        form.control("cantidadJugadores").value -= 1;
      } else {
        Fun.toast(type: ToasType.warning, context: context, message: "La cantidad de jugadores no puede ser menor a 2.");
      }
    }
    notifyListeners();
  }

  rellenarFormulario(PartidaPredefinida partida) {
    form.patchValue(partida.toMap());
    partidaPredefinidaEditar = partida;
    notifyListeners();
  }

  resetForm() async {
    form.reset();

    form.control("maxPuntuacion").value = 1;
    form.control("cantidadJugadores").value = 2;
    form.control("orden").value = partidasPredefinidas.length + 1;
    notifyListeners();

    return Future.delayed(const Duration(milliseconds: 10));
  }

  seed() async {
    Fun.logColor(color: Colores.yellow, body: ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    Fun.logColor(color: Colores.yellow, body: "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    Fun.logColor(color: Colores.yellow, body: "SEED DE PARTIDAS PREDEFINIDAS");
    Fun.logColor(color: Colores.yellow, body: ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    Fun.logColor(color: Colores.yellow, body: "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");

    List<PartidaPredefinida> listado = [PartidaPredefinida(nombre: "Domino", orden: 1, tipo: "Puntuación", maxPuntuacion: 200, cantidadJugadores: 2)];

    Fun.logColor(color: Colores.magenta, body: "LENGTH: ${listado.length}");

    for (var index = 0; index < listado.length; index++) {
      PartidaPredefinida partida = listado[index];
      partida.orden = index += 1;
      await newPartida(partida: partida, isLoading: false);
    }

    Preferences.isFirstTimeOpen = false;
  }

  Future<SqlResponse> newPartida({required PartidaPredefinida partida, bool? isLoading = true}) async {
    final response = await PartidaPredefinida.createPartidaPredefinida(partida: partida, isLoading: isLoading!);
    PartidaPredefinida newPartida = response.data;

    partidasPredefinidas.add(newPartida);
    partidaPredefinidaEditar = null;
    notifyListeners();

    return response;
  }

  Future<SqlResponse> editPartida(BuildContext context, {required PartidaPredefinida partida, required Map<String, dynamic> partidaEdit}) async {
    final responseFuture = PartidaPredefinida.edit(id: partida.id!, partidaEdit: partidaEdit);
    final response = await responseFuture;

    if (!response.hasError!) {
      notifyListeners();
      return responseFuture;
    } else {
      Fun.toast(type: ToasType.error, context: context, message: response.messages!.first);
      return responseFuture;
    }
  }

  Future getPartidasPredefinidas(context, {required bool isLoading}) async {
    await Future.delayed(const Duration(microseconds: 100));

    final partidasFuture = PartidaPredefinida.getPartidasPredefinidas(isLoading: isLoading);
    partidasPredefinidas = await partidasFuture;

    notifyListeners();
    return partidasFuture;
  }

  Future<SqlResponse> deletePartidaPredefinida(BuildContext context, {required PartidaPredefinida partida}) async {
    final response = await PartidaPredefinida.delete(partida: partida, isLoading: true);

    if (!response.hasError!) {
      partidasPredefinidas.remove(partida);
      notifyListeners();
      return response;
    } else {
      Fun.toast(type: ToasType.error, context: context, message: response.messages!.first);
      return response;
    }
  }
}
