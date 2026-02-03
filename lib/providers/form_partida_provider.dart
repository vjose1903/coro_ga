import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/partida_predefinida.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FormPartidaProvider extends ChangeNotifier {
  FormGroup form = fb.group({
    'nombre': ['', Validators.required],
    'activo': ['true'],
    'tipo': ['', Validators.required],
    'maxPuntuacion': [1, Validators.min(1)],
    'jugadores': fb.array([])
  });

  bool sinMaxPuntuacion = false;

  void rellenarFormulario(PartidaPredefinida partidaPredefinida, {BuildContext? context}) async {
    await resetForm(restoreJugadores: false);
    form.patchValue(partidaPredefinida.toMap());
    _syncSinMaxWithValue();

    for (var index = 0; index < partidaPredefinida.cantidadJugadores!; index++) {
      final String playerName = context != null 
          ? AppLocalizations.of(context)!.playerNumber(index + 1)
          : 'Player ${index + 1}';
      addJugadorToList(name: playerName);
    }

    notifyListeners();
  }

  void changeTipo(value) {
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

  resetForm({bool restoreJugadores = true}) {
    form.reset();

    final jugadoresArray = form.control('jugadores') as FormArray<dynamic>;

    if (jugadoresArray.value != null && jugadoresArray.value!.isNotEmpty) {
      final longitud = jugadoresArray.value!.length;
      for (var index = 0; index < longitud; index++) {
        jugadoresArray.removeAt(0);
      }
    }

    if (restoreJugadores) {
      for (var i = 0; i < List.from([1, 2]).length; i++) {
        addJugadorToList();
      }
    }

    form.control('activo').value = 'true';
    form.control('maxPuntuacion').setValidators([Validators.min(1)]);
    form.control('maxPuntuacion').value = 1;
    sinMaxPuntuacion = false;
    notifyListeners();
    // return Future.delayed(const Duration(milliseconds: 10));
  }

  get jugadores {
    final jugadoresArray = form.control('jugadores').value;
    return jugadoresArray ?? [];
  }

  void addJugadorToList({String? name}) {
    final jugadoresArray = form.control('jugadores') as FormArray<dynamic>;
    final newFormGroup = createItem(cant: 1, name: name).first;

    jugadoresArray.add(newFormGroup);

    notifyListeners();
  }

  void removeJugadorToList(int index) {
    final jugadoresArray = form.control('jugadores') as FormArray<dynamic>;
    jugadoresArray.removeAt(index);

    notifyListeners();
  }

  static List<FormGroup> createItem({required int cant, String? name}) {
    final List<FormGroup> jugadoresForm = List<FormGroup>.from([]);

    for (var i = 0; i < cant; i++) {
      jugadoresForm.add(fb.group({
        'nombre': [name ?? '', Validators.required]
      }));
    }
    return jugadoresForm;
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
