import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../helpers/helpers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

/// Widget centralizado para headers de SlideUp panels.
/// Incluye la decoración neumórfica y el gesto de drag para controlar el panel.
class HeaderSection extends StatefulWidget {
  const HeaderSection({
    required this.panelController,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.useLandscapeLayout,
    required this.isWide,
    this.subtitle,
    this.rightWidget,
    super.key,
  });

  final PanelController? panelController;
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String? subtitle;
  final bool useLandscapeLayout;
  final bool isWide;
  final Widget? rightWidget;

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  double _dragStartPosition = 1.0;
  double _dragAccumulated = 0.0;
  double? _panelMaxHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;
    final avatarSize = widget.useLandscapeLayout ? (widget.isWide ? 36.0 : 37.0) : 42.0;
    final iconSize = widget.useLandscapeLayout ? 13.0 : 18.0;

    return GestureDetector(
      onVerticalDragStart: (details) {
        if (widget.panelController == null || !widget.panelController!.isAttached) return;
        _dragStartPosition = widget.panelController!.panelPosition;
        _dragAccumulated = 0.0;
        // Obtener la altura máxima del panel desde el contexto
        _panelMaxHeight ??= MediaQuery.of(context).size.height * 0.95;
      },
      onVerticalDragUpdate: (details) {
        if (widget.panelController == null || !widget.panelController!.isAttached || _panelMaxHeight == null) return;

        // Acumular el delta del drag
        _dragAccumulated += details.delta.dy;

        // Calcular la nueva posición (invertir porque drag down = posición menor)
        final dragFraction = _dragAccumulated / _panelMaxHeight!;
        final newPosition = (_dragStartPosition - dragFraction).clamp(0.0, 1.0);

        // Mover el panel a la nueva posición
        widget.panelController!.panelPosition = newPosition;
      },
      onVerticalDragEnd: (details) {
        if (widget.panelController == null || !widget.panelController!.isAttached) return;

        final velocity = details.primaryVelocity ?? 0;
        final currentPosition = widget.panelController!.panelPosition;

        // Si la velocidad es alta hacia abajo o la posición es menor al 50%, cerrar
        if (velocity > 300 || currentPosition < 0.5) {
          widget.panelController!.close();
        } else {
          // Volver a abrir completamente
          widget.panelController!.open();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)] : [AppThemes.colorPrimero.withValues(alpha: 0.08), AppThemes.colorPrimero.withValues(alpha: 0.03)],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.iconBackgroundColor,
                      widget.iconBackgroundColor.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconBackgroundColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  // Compensa el baseline de algunos icon fonts (ej. FontAwesome)
                  // para que el icono quede visualmente centrado.
                  child: Transform.translate(
                    offset: const Offset(-2.0, 0.8),
                    child: IconScale(widget.icon, color: Colors.white, size: iconSize),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: widget.useLandscapeLayout
                    ? Row(
                        children: [
                          Flexible(
                            child: TextScale(
                              widget.title,
                              size: 14,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppThemes.colorQuinto,
                              ),
                            ),
                          ),
                          if ((widget.subtitle ?? '').isNotEmpty) ...[
                            SizedBox(width: ResponsiveApp.scaleWidth(4)),
                            Flexible(
                              child: TextScale(
                                widget.subtitle!,
                                size: 11,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextScale(
                            widget.title,
                            size: 14,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppThemes.colorQuinto,
                            ),
                          ),
                          if ((widget.subtitle ?? '').isNotEmpty) ...[
                            const SizedBox(height: 1),
                            TextScale(
                              widget.subtitle!,
                              size: 11,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              if (widget.rightWidget != null) ...[
                const SizedBox(width: 10),
                widget.rightWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
