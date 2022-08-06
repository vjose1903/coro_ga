import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

import 'package:we_slide/we_slide.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? Body;
  Widget? Footer;

  set body(Widget? widget) {
    Body = widget;
  }

  set footer(Widget? widget) {
    Footer = widget;
  }

  openSlideUp({required SlidingUpPanelController controller, Widget? body, Widget? footer}) async {
    if (body != null) Body = body;
    if (footer != null) Footer = footer;

    controller.expand();
    notifyListeners();
  }

  closeSlideUp({required SlidingUpPanelController controller, bool isListener = false}) async {
    if (!isListener) controller.collapse();
    notifyListeners();
  }
}
