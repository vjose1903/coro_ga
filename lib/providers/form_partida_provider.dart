import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FormPartidaProvider extends ChangeNotifier {
  FormGroup formPartida = fb.group({
    'nombre': ['', Validators.required],
    'activo': ["true"],
    'tipo': ['', Validators.required],
    'maxPuntuacion': [1, Validators.min(1)],
    'jugadores': fb.array(createItem(2))
  });

  void changeTipo(value) {
    notifyListeners();
  }

  void resetForm() {
    formPartida.reset();

    final jugadoresArray = formPartida.control('jugadores') as FormArray<dynamic>;
    print("jugadoresArray.value: ${jugadoresArray.value}");
    if (jugadoresArray.value != []) {
      for (var index = 0; index <= jugadoresArray.value!.length; index++) {
        print("");
        print("index: $index");
        jugadoresArray.removeAt(0);
      }
    }
    for (var i = 0; i < List.from([1, 2]).length; i++) {
      addJugadorToList();
    }
    // jugadoresArray.value = createItem(2);

    notifyListeners();
  }

  get jugadores {
    final jugadoresArray = formPartida.control('jugadores').value;
    return jugadoresArray ?? [];
  }

  void addJugadorToList() {
    final jugadoresArray = formPartida.control('jugadores') as FormArray<dynamic>;
    final newFormGroup = createItem(1).first;
    jugadoresArray.add(newFormGroup);
    print(jugadoresArray.value);
    notifyListeners();
  }

  void removeJugadorToList(int index) {
    final jugadoresArray = formPartida.control('jugadores') as FormArray<dynamic>;
    jugadoresArray.removeAt(index);

    notifyListeners();
  }

  static List<FormGroup> createItem(count) {
    List<FormGroup> jugadoresForm = List<FormGroup>.from([]);

    for (var i = 0; i < count; i++) {
      jugadoresForm.add(fb.group({
        'nombre': ['', Validators.required]
      }));
    }
    return jugadoresForm;
  }
}
