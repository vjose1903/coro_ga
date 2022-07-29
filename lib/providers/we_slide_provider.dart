import 'package:flutter/material.dart';

import 'package:we_slide/we_slide.dart';

class WeSlideProvider extends ChangeNotifier {
  Widget? Body;
  Widget? Footer;

  set body(Widget? widget) {
    Body = widget;
  }

  set footer(Widget? widget) {
    Footer = widget;
  }

  openWeSlide({required WeSlideController controller, Widget? body, Widget? footer}) async {
    if (body != null) Body = body;
    if (footer != null) Footer = footer;

    controller.show();
    notifyListeners();
  }

  closeWeSlide({required WeSlideController controller, bool isListener = false}) async {
    if (!isListener) controller.hide();
    notifyListeners();
  }
}
