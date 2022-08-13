import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  bool isLoading = false;

  changeIsLoading(value) {
    isLoading = value;
    notifyListeners();  
  }
}
