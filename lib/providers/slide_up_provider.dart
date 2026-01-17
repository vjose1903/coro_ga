import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? body;
  double? _topMargin;
  double? _maxHeightFraction;
  bool _closeOnOutsideClick = true;

  double? get topMargin => _topMargin;
  double? get maxHeightFraction => _maxHeightFraction;
  bool get closeOnOutsideClick => _closeOnOutsideClick;

  void openSlideUp({
    required PanelController controller,
    Widget? bodyContent,
    double? topMargin,
    double? maxHeightFraction, // Altura máxima como fracción de la pantalla (0.5 = 50%)
    bool closeOnOutsideClick = true,
  }) {
    if (bodyContent != null) body = bodyContent;
    _topMargin = topMargin;
    _maxHeightFraction = maxHeightFraction;
    _closeOnOutsideClick = closeOnOutsideClick;
    
    // Usar microtask para evitar rebuild durante build
    Future.microtask(() {
      if (controller.isAttached) controller.open();
      notifyListeners();
    });
  }

  void closeSlideUp({required PanelController controller, bool isListener = false}) {
    if (!isListener && controller.isAttached) controller.close();
    _topMargin = null;
    _maxHeightFraction = null;
    _closeOnOutsideClick = true;
    notifyListeners();
  }
}
