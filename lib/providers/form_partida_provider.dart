import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/partida_predefinida.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FormPartidaProvider extends ChangeNotifier {
  static const int _minJugadores = 2;
  static const int _maxJugadores = 20;
  static const int _defaultMaxPuntuacion = 1;

  FormGroup form = _buildBaseForm();

  bool sinMaxPuntuacion = false;

  void rellenarFormulario(
    PartidaPredefinida partidaPredefinida, {
    BuildContext? context,
  }) {
    // Mismo flujo que al inicializar el formulario para asegurar nombres por defecto.
    resetForm(restoreJugadores: false);

    form.control('nombre').value = partidaPredefinida.nombre ?? '';
    form.control('tipo').value = partidaPredefinida.tipo ?? '';
    form.control('activo').value = 'true';
    form.control('maxPuntuacion').value =
        partidaPredefinida.maxPuntuacion ?? _defaultMaxPuntuacion;
    _syncSinMaxWithValue();

    final targetJugadores =
        (partidaPredefinida.cantidadJugadores ?? _minJugadores)
            .clamp(_minJugadores, _maxJugadores);
    _setPlayersCount(targetJugadores, context: context);
    form.updateValueAndValidity();

    notifyListeners();
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

  resetForm({bool restoreJugadores = true, BuildContext? context}) {
    // Crear un FormGroup nuevo evita estado residual en controles reactivos.
    form = _buildBaseForm();
    if (restoreJugadores) {
      _setPlayersCount(_minJugadores, context: context);
    }

    form.control('activo').value = 'true';
    form.control('maxPuntuacion').setValidators([Validators.min(1)]);
    form.control('maxPuntuacion').value = _defaultMaxPuntuacion;
    sinMaxPuntuacion = false;
    notifyListeners();
  }

  List<dynamic> get jugadores {
    final jugadoresArray = form.control('jugadores').value;
    return jugadoresArray ?? [];
  }

  void addJugadorToList({String? name, BuildContext? context}) {
    final jugadoresArray = form.control('jugadores') as FormArray<dynamic>;
    final playerNumber = jugadoresArray.controls.length + 1;
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name
        : _defaultPlayerName(context, playerNumber);
    final newFormGroup = createItem(cant: 1, name: resolvedName).first;

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

  String _defaultPlayerName(BuildContext? context, int number) {
    if (context == null) return 'Jugador $number';
    return AppLocalizations.of(context)!.playerNumber(number);
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

  static FormGroup _buildBaseForm() => fb.group({
        'nombre': ['', Validators.required],
        'activo': ['true'],
        'tipo': ['', Validators.required],
        'maxPuntuacion': [_defaultMaxPuntuacion, Validators.min(1)],
        'jugadores': fb.array([]),
      });

  void _setPlayersCount(int targetCount, {BuildContext? context}) {
    final jugadoresArray = form.control('jugadores') as FormArray<dynamic>;
    while (jugadoresArray.controls.length < targetCount) {
      final nextNumber = jugadoresArray.controls.length + 1;
      jugadoresArray.add(
        fb.group({
          'nombre': [_defaultPlayerName(context, nextNumber), Validators.required],
        }),
      );
    }
    while (jugadoresArray.controls.length > targetCount) {
      jugadoresArray.removeAt(jugadoresArray.controls.length - 1);
    }
  }
}
