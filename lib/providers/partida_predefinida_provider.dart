import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/utils/utils.dart';

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

  get cantidadJugadores {
    final cantidadJugadores = form.control('cantidadJugadores').value;
    
    return cantidadJugadores ?? 0;
  }

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
        Toast.show(type: ToastType.warning, context: context, message: "La cantidad de jugadores no puede ser menor a 2.");
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
    partidaPredefinidaEditar = null;
    notifyListeners();

    return Future.delayed(const Duration(milliseconds: 10));
  }

  seed() async {
    List<PartidaPredefinida> listado = [PartidaPredefinida(nombre: "Domino", orden: 1, tipo: "Puntuación", maxPuntuacion: 200, cantidadJugadores: 2)];

    for (var index = 0; index < listado.length; index++) {
      PartidaPredefinida partida = listado[index];
      partida.orden = index += 1;
      await newPartida(partida: partida);
    }

    Preferences.isFirstTimeOpen = false;
  }

  Future<SqlResponse> newPartida({required PartidaPredefinida partida}) async {
    partida.orden = partidasPredefinidas.length + 1;

    final response = await PartidaPredefinida.createPartidaPredefinida(partida: partida);
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
      Toast.show(type: ToastType.error, context: context, message: response.messages!.first);
      return responseFuture;
    }
  }

  Future getPartidasPredefinidas() async {
    await Future.delayed(const Duration(microseconds: 100));

    final partidasFuture = PartidaPredefinida.getPartidasPredefinidas();
    partidasPredefinidas = await partidasFuture;

    notifyListeners();
    return partidasFuture;
  }

  Future<SqlResponse> deletePartidaPredefinida(BuildContext context, {required PartidaPredefinida partida}) async {
    final response = await PartidaPredefinida.delete(partida: partida);

    if (!response.hasError!) {
      partidasPredefinidas.remove(partida);
      notifyListeners();
      return response;
    } else {
      Toast.show(type: ToastType.error, context: context, message: response.messages!.first);
      return response;
    }
  }
}
