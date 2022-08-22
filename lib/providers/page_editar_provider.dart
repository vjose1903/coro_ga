import 'package:flutter/material.dart';

class PageEditarProvider extends ChangeNotifier {
  double actualPage = 0.0;

  getActualPage() {
    return actualPage;
  }

  setActualPage(newPage) {
    actualPage = newPage;
  }
}
