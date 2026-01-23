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

  void rellenarFormulario(PartidaPredefinida partidaPredefinida, {BuildContext? context}) async {
    await resetForm(restoreJugadores: false);
    form.patchValue(partidaPredefinida.toMap());

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
}
