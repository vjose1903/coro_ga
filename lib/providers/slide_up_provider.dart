import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? body;
  double? _topMargin;
  double? _maxHeightFraction;
  bool _closeOnOutsideClick = true;
  bool _isPanelFullyOpen = false;

  // Callbacks para scroll automático pendiente
  final List<VoidCallback> _pendingScrollCallbacks = [];

  double? get topMargin => _topMargin;
  double? get maxHeightFraction => _maxHeightFraction;
  bool get closeOnOutsideClick => _closeOnOutsideClick;
  bool get isPanelFullyOpen => _isPanelFullyOpen;

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

    // Si el panel ya está abierto, solo notificar para actualizar el contenido
    if (controller.isAttached && controller.isPanelOpen) {
      notifyListeners();
      return;
    }

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
    _isPanelFullyOpen = false;
    _pendingScrollCallbacks.clear();
    notifyListeners();
  }

  /// Llamado cuando el panel está completamente abierto
  void onPanelOpened() {
    _isPanelFullyOpen = true;
    // Ejecutar callbacks pendientes
    for (final callback in _pendingScrollCallbacks) {
      callback();
    }
    _pendingScrollCallbacks.clear();
    notifyListeners();
  }

  /// Llamado cuando el panel comienza a cerrarse
  void onPanelClosing() {
    _isPanelFullyOpen = false;
    _pendingScrollCallbacks.clear();
  }

  /// Registra un callback para ejecutar cuando el panel esté completamente abierto
  /// Si el panel ya está abierto, ejecuta el callback inmediatamente
  void executeWhenPanelOpen(VoidCallback callback) {
    if (_isPanelFullyOpen) {
      callback();
    } else {
      _pendingScrollCallbacks.add(callback);
    }
  }
}
