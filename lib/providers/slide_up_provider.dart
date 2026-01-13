import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? body;

  void openSlideUp({required SlidingUpPanelController controller, Widget? bodyContent}) {
    if (bodyContent != null) body = bodyContent;
    
    // Usar microtask para evitar rebuild durante build
    Future.microtask(() {
      controller.expand();
      notifyListeners();
    });
  }

  void closeSlideUp({required SlidingUpPanelController controller, bool isListener = false}) {
    if (!isListener) controller.collapse();
    notifyListeners();
  }
}
