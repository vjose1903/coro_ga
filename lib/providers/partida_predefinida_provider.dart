import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../shared_preferences/preferences.dart';
import '../utils/utils.dart';

class PartidaPredefinidaProvider extends ChangeNotifier {
  List<PartidaPredefinida> partidasPredefinidas = [];
  PartidaPredefinida? partidaPredefinidaEditar;
  bool sinMaxPuntuacion = false;

  FormGroup form = fb.group({
    'nombre': ['', Validators.required],
    'tipo': ['', Validators.required],
    'maxPuntuacion': [1, Validators.min(1)],
    'cantidadJugadores': [2, Validators.min(2)],
    'orden': [null]
  });

  dynamic get cantidadJugadores {
    final cantidadJugadores = form.control('cantidadJugadores').value;

    return cantidadJugadores ?? 0;
  }

  void changeTipo(dynamic value) {
    notifyListeners();
  }

  void setSinMaxPuntuacion(bool value) {
    if (sinMaxPuntuacion == value) return;
    sinMaxPuntuacion = value;
    final control = form.control('maxPuntuacion');
    if (sinMaxPuntuacion) {
      control.setValidators([]);
      control.value = null;
    } else {
      control.setValidators([Validators.min(1)]);
      final current = control.value;
      if (current == null || current == '' || current == 0 || current == '0') {
        control.value = 1;
      }
    }
    control.updateValueAndValidity();
    notifyListeners();
  }

  void changeCantidadJugadores(
      {required String tipo, required BuildContext context}) {
    print(
        "formPartidaPredefinida.control(cantidadJugadores).value: ${form.control("cantidadJugadores").value} ");
    final int actualCantidad = form.control('cantidadJugadores').value;

    if (tipo == '+') {
      form.control('cantidadJugadores').value += 1;
    } else {
      if (actualCantidad > 2) {
        form.control('cantidadJugadores').value -= 1;
      } else {
        final l10n = AppLocalizations.of(context)!;
        Toast.show(
            type: ToastType.warning,
            context: context,
            message: l10n.minPlayersWarning);
      }
    }
    notifyListeners();
  }

  void rellenarFormulario(PartidaPredefinida partida) {
    form.patchValue(partida.toMap());
    partidaPredefinidaEditar = partida;
    _syncSinMaxWithValue();
    notifyListeners();
  }

  Future<Future<dynamic>> resetForm() async {
    form.reset();
    form.control('maxPuntuacion').value = 1;
    form.control('maxPuntuacion').setValidators([Validators.min(1)]);
    form.control('cantidadJugadores').value = 2;
    partidaPredefinidaEditar = null;
    sinMaxPuntuacion = false;
    notifyListeners();

    return Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> seed() async {
    final List<PartidaPredefinida> listado = [
      PartidaPredefinida(
          nombre: 'Domino',
          orden: 1,
          tipo: 'Puntuación',
          maxPuntuacion: 200,
          cantidadJugadores: 2)
    ];

    for (var index = 0; index < listado.length; index++) {
      final PartidaPredefinida partida = listado[index];
      partida.orden = index += 1;
      await newPartida(partida: partida);
    }

    Preferences.isFirstTimeOpen = false;
  }

  Future<SqlResponse> newPartida({required PartidaPredefinida partida}) async {
    partida.orden = partidasPredefinidas.length + 1;

    final response =
        await PartidaPredefinida.createPartidaPredefinida(partida: partida);
    final PartidaPredefinida newPartida = response.data;

    partidasPredefinidas.add(newPartida);
    partidaPredefinidaEditar = null;
    notifyListeners();

    return response;
  }

  Future<SqlResponse> editPartida(BuildContext context,
      {required PartidaPredefinida partida,
      required Map<String, dynamic> partidaEdit}) async {
    final SqlResponse response = await PartidaPredefinida.edit(
        id: partida.id!, partidaEdit: partidaEdit);

    if (!response.hasError!) {
      notifyListeners();
      return response;
    }

    if (!context.mounted) {
      return response;
    }
    Toast.show(
      type: ToastType.error,
      context: context,
      message: response.messages!.first,
    );
    return response;
  }

  Future getPartidasPredefinidas() async {
    await Future.delayed(const Duration(microseconds: 100));

    final partidasFuture = PartidaPredefinida.getPartidasPredefinidas();
    partidasPredefinidas = await partidasFuture;

    notifyListeners();
    return partidasFuture;
  }

  Future<SqlResponse> deletePartidaPredefinida(BuildContext context,
      {required PartidaPredefinida partida}) async {
    final response = await PartidaPredefinida.delete(partida: partida);

    if (!response.hasError!) {
      partidasPredefinidas.remove(partida);
      notifyListeners();
      return response;
    }
    if (!context.mounted) {
      return response;
    }
    Toast.show(
        type: ToastType.error,
        context: context,
        message: response.messages!.first);
    return response;
  }

  void _syncSinMaxWithValue() {
    final control = form.control('maxPuntuacion');
    final value = control.value;
    final bool isSinMax = value == null || value == 0 || value == '0';
    sinMaxPuntuacion = isSinMax;
    if (isSinMax) {
      control.setValidators([]);
    } else {
      control.setValidators([Validators.min(1)]);
    }
    control.updateValueAndValidity();
  }
}
