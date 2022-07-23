import 'package:flutter/material.dart';
import 'package:game_score/utils/utils.dart';

import 'package:we_slide/we_slide.dart';

class MyWeSlide {
  static WeSlideController? controller;
  static Widget? body;
  static Widget? footer;

  static initialize() {
    if (controller == null) {
      Fun.logColor(color: Colores.red, body: "----- AGREGANDO CONTROLLER -----");

      controller = WeSlideController();
    }
  }

  static configureWeSlide({Widget? weSlidecontent, Widget? weSlideFooter}) {
    Fun.logColor(color: Colores.white, body: "----- CONFIGURANDO WESLIDE -----");
    body = weSlidecontent;
    footer = weSlideFooter;
  }

  static open() {
    if (controller == null) return;
    print("OPEN");
    print(" ");
    controller!.show();
  }

  static close() {
    if (controller == null) return;
    print("CLOSE");
    print(" ");
    controller!.hide();
  }
}
