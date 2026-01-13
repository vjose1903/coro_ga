import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? body;
  double? _topMargin;
  bool _closeOnOutsideClick = true;

  double? get topMargin => _topMargin;
  bool get closeOnOutsideClick => _closeOnOutsideClick;

  void openSlideUp({
    required SlidingUpPanelController controller,
    Widget? bodyContent,
    double? topMargin,
    bool closeOnOutsideClick = true,
  }) {
    if (bodyContent != null) body = bodyContent;
    _topMargin = topMargin;
    _closeOnOutsideClick = closeOnOutsideClick;
    
    // Usar microtask para evitar rebuild durante build
    Future.microtask(() {
      controller.expand();
      notifyListeners();
    });
  }

  void closeSlideUp({required SlidingUpPanelController controller, bool isListener = false}) {
    if (!isListener) controller.collapse();
    _topMargin = null;
    _closeOnOutsideClick = true;
    notifyListeners();
  }
}
