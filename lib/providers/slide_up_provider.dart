import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class SlideUpProvider extends ChangeNotifier {
  Widget? body;
  double? _topMargin;
  double? _maxHeightFraction;
  bool _closeOnOutsideClick = true;
  bool _isPanelFullyOpen = false;
  double _panelPosition = 0.0;
  double _panelMaxHeight = 0.0;
  bool _isResizing = false;
  bool _skipCleanOnClose = false;
  bool _isDraggable = false;

  // Callbacks para scroll automático pendiente
  final List<VoidCallback> _pendingScrollCallbacks = [];

  double? get topMargin => _topMargin;
  double? get maxHeightFraction => _maxHeightFraction;
  bool get closeOnOutsideClick => _closeOnOutsideClick;
  bool get isPanelFullyOpen => _isPanelFullyOpen;
  double get panelPosition => _panelPosition;
  double get panelMaxHeight => _panelMaxHeight;
  bool get isResizing => _isResizing;
  bool get skipCleanOnClose => _skipCleanOnClose;
  bool get isDraggable => _isDraggable;

  set isResizing(bool value) {
    if (_isResizing != value) {
      _isResizing = value;
      notifyListeners();
    }
  }

  void setDraggable(bool value) {
    if (_isDraggable != value) {
      _isDraggable = value;
      notifyListeners();
    }
  }

  set panelMaxHeight(double value) {
    _panelMaxHeight = value;
  }

  void openSlideUp({
    required PanelController controller,
    Widget? bodyContent,
    double? topMargin,
    double? maxHeightFraction, // Altura máxima como fracción de la pantalla (0.5 = 50%)
    bool closeOnOutsideClick = true,
    bool isDraggable = false,
  }) {
    if (bodyContent != null) body = bodyContent;
    _topMargin = topMargin;
    _maxHeightFraction = maxHeightFraction;
    _closeOnOutsideClick = closeOnOutsideClick;
    _isDraggable = isDraggable;

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

  void closeSlideUp({required PanelController controller, bool isListener = false, bool skipClean = false}) {
    _skipCleanOnClose = skipClean;
    if (!isListener && controller.isAttached) controller.close();
    _topMargin = null;
    _maxHeightFraction = null;
    _closeOnOutsideClick = true;
    _isPanelFullyOpen = false;
    _panelPosition = 0.0;
    _isDraggable = false;
    _pendingScrollCallbacks.clear();
    // Solo notificar si no es llamado desde un listener (evita rebuilds innecesarios)
    if (!isListener) notifyListeners();
  }

  void resetSkipClean() {
    _skipCleanOnClose = false;
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

  /// Actualiza la posición del panel (0 = cerrado, 1 = abierto)
  void updatePanelPosition(double position) {
    if (_panelPosition != position) {
      _panelPosition = position;
      notifyListeners();
    }
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
