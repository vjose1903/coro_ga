import 'package:flutter/material.dart';
import 'package:game_score/utils/utils.dart';

import 'package:we_slide/we_slide.dart';

class WeSlideProvider extends ChangeNotifier {
  refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  configureWeSlide({Widget? weSlidecontent, Widget? weSlideFooter}) async {
    MyWeSlide.configureWeSlide(weSlidecontent: weSlidecontent, weSlideFooter: weSlideFooter);

    // await Future.delayed(const Duration(milliseconds: 500));
    // notifyListeners();
  }

  openWeSlide() async {
    if (MyWeSlide.controller == null) return;
    print("ABRIENDO");

    MyWeSlide.open();
    notifyListeners();
  }

  closeWeSlide() async {
    notifyListeners();
    if (MyWeSlide.controller == null) return;
    print("CERRANDO");
    MyWeSlide.close();

    await Future.delayed(const Duration(milliseconds: 250));
  }
}
