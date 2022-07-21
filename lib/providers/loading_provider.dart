import 'package:flutter/material.dart';

import 'package:we_slide/we_slide.dart';

class LoadingProvider extends ChangeNotifier {
  bool isLoading = false;

  changeIsLoading(value) {
    isLoading = value;
    notifyListeners();
  }
}
