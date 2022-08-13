import 'package:flutter/material.dart';
import 'package:game_score/utils/functions.dart';

class ReorderableProvider extends ChangeNotifier {
  bool _isReording = false;

  set isReording(value) {
    _isReording = value;
    notifyListeners();
  }

  bool get isReording => _isReording;

  void onReorder({required int oldIndex, required int newIndex, required reordenableList}) {
    Fun.logColor(color: Colores.white, body: "--- ON REORDER ---");
    Widget row = reordenableList.removeAt(oldIndex);
    reordenableList.insert(newIndex, row);
  }

  void changesOnList() {
    notifyListeners();
  }
}
