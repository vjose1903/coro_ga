import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FormPartidaProvider extends ChangeNotifier {
  FormGroup formPartida = fb.group({
    'nombre': ['', Validators.required],
    'jugadores': fb.array(createItem(2)),
    'tipo': ['', Validators.required],
    'maxPuntuacion': [1, Validators.min(1)]
  });

  void changeTipo(value) {
    print(value);
    notifyListeners();
  }

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

  void addJugadorToList() {
    if (partida == null) return;
    final formJugadoresArray = formPartida.control('jugadores') as FormArray<dynamic>;
    final newFormGroup = createItem(1).first;
    formJugadoresArray.add(newFormGroup);
    notifyListeners();
  }

  void removeJugadorToList(int index) {
    if (partida == null) return;
    final formJugadoresArray = formPartida.control('jugadores') as FormArray<dynamic>;
    formJugadoresArray.removeAt(index);

    notifyListeners();
  }

  static List<FormGroup> createItem(count) {
    List<FormGroup> jugadoresForm = List<FormGroup>.from([]);

    FormGroup moldeForm = fb.group({
      'nombre': ['', Validators.required]
    });

    for (var i = 0; i < count; i++) {
      jugadoresForm.add(moldeForm);
    }
    return jugadoresForm;
  }
}
