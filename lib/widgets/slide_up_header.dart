import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';

/// Widget centralizado para headers de SlideUp panels.
/// Incluye la decoración neumórfica y el gesto de drag para controlar el panel.
class SlideUpHeader extends StatefulWidget {
  const SlideUpHeader({
    super.key,
    required this.panelController,
    required this.child,
  });

  final PanelController panelController;
  final Widget child;

  @override
  State<SlideUpHeader> createState() => _SlideUpHeaderState();
}

class _SlideUpHeaderState extends State<SlideUpHeader> {
  double _dragStartPosition = 1.0;
  double _dragAccumulated = 0.0;
  double? _panelMaxHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return GestureDetector(
      onVerticalDragStart: (details) {
        if (!widget.panelController.isAttached) return;
        _dragStartPosition = widget.panelController.panelPosition;
        _dragAccumulated = 0.0;
        // Obtener la altura máxima del panel desde el contexto
        _panelMaxHeight ??= MediaQuery.of(context).size.height * 0.95;
      },
      onVerticalDragUpdate: (details) {
        if (!widget.panelController.isAttached || _panelMaxHeight == null) return;

        // Acumular el delta del drag
        _dragAccumulated += details.delta.dy;

        // Calcular la nueva posición (invertir porque drag down = posición menor)
        final dragFraction = _dragAccumulated / _panelMaxHeight!;
        final newPosition = (_dragStartPosition - dragFraction).clamp(0.0, 1.0);

        // Mover el panel a la nueva posición
        widget.panelController.panelPosition = newPosition;
      },
      onVerticalDragEnd: (details) {
        if (!widget.panelController.isAttached) return;

        final velocity = details.primaryVelocity ?? 0;
        final currentPosition = widget.panelController.panelPosition;

        // Si la velocidad es alta hacia abajo o la posición es menor al 50%, cerrar
        if (velocity > 300 || currentPosition < 0.5) {
          widget.panelController.close();
        } else {
          // Volver a abrir completamente
          widget.panelController.open();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
                : [AppThemes.colorPrimero.withValues(alpha: 0.08), AppThemes.colorPrimero.withValues(alpha: 0.03)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppThemes.colorPrimero.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
