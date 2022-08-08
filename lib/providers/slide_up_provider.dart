import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? body;

  openSlideUp({required SlidingUpPanelController controller, Widget? bodyContent}) async {

    if (bodyContent != null) body = bodyContent;

    await Future.delayed(const Duration(milliseconds: 100));
    controller.expand();
    notifyListeners();
  }

  closeSlideUp({required SlidingUpPanelController controller, bool isListener = false}) async {
    if (!isListener) controller.collapse();
    notifyListeners();
  }
}
