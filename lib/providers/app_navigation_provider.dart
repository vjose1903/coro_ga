import 'package:flutter/foundation.dart';

class AppNavigationProvider extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void showHome() {
    if (_index == 0) return;
    _index = 0;
    notifyListeners();
  }

  void showPartida() {
    if (_index == 1) return;
    _index = 1;
    notifyListeners();
  }
}
