import 'package:flutter/material.dart';

class PageEditarProvider extends ChangeNotifier {
  double actualPage = 0.0;

  double getActualPage() {
    return actualPage;
  }

  void setActualPage(double newPage) {
    actualPage = newPage;
  }
}
