import 'package:flutter/material.dart';

class ReorderableProvider extends ChangeNotifier {
  bool _isReording = false;

  set isReording(bool value) {
    _isReording = value;
    notifyListeners();
  }

  bool get isReording => _isReording;

  void onReorder({
    required int oldIndex,
    required int newIndex,
    required List<Widget> reordenableList,
  }) {
    final Widget row = reordenableList.removeAt(oldIndex);
    reordenableList.insert(newIndex, row);
  }

  void changesOnList() {
    notifyListeners();
  }
}
