import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:provider/provider.dart';

class Layout extends StatefulWidget {
  const Layout({
    Key? key,
    required this.bodyContent,
    required this.panelController,
    this.appBarTitle,
    this.appBarLeading,
    this.appBarTrailing,
    this.hasFooter = false,
    this.maxPanelHeightFraction = 0.95,
  }) : super(key: key);

  final Widget bodyContent;
  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;
  final bool? hasFooter;
  final double maxPanelHeightFraction;

  final PanelController panelController;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late final ScrollController _panelScrollController;

  // Gradiente moderno para el fondo
  static const boxDecoration = BoxDecoration(
    gradient: LinearGradient(
      transform: GradientRotation(-0.4),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.4, 1.0],
      colors: [
        Color(0xFF3D47D9),
        Color(0xFF1A237E),
        Color(0xFF0D1442),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    _panelScrollController = ScrollController();
  }

  @override
  void dispose() {
    _panelScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final topPadding = mediaQuery.padding.top;

    final fraction = slideUpProvider.maxHeightFraction ?? widget.maxPanelHeightFraction;
    final visibleHeight = screenHeight - keyboardHeight;
    final minTopMargin = topPadding + 40;

    final maxHeight = max(
      100.0,
      min(
        screenHeight * fraction,
        min(visibleHeight * widget.maxPanelHeightFraction, visibleHeight - minTopMargin),
      ),
    );

    final isDark = Preferences.isDarkMode;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SlidingUpPanel(
        controller: widget.panelController,
        scrollController: _panelScrollController,
        minHeight: 0,
        maxHeight: maxHeight,
        backdropEnabled: true,
        parallaxEnabled: true,
        backdropOpacity: 0.7,
        backdropTapClosesPanel: slideUpProvider.closeOnOutsideClick,
        isDraggable: slideUpProvider.isDraggable,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 2,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          if (!isDark)
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, -2),
              color: Colors.white.withValues(alpha: 0.1),
            ),
        ],
        color: AppThemes.themeColor_2,
        onPanelOpened: () {
          slideUpProvider.onPanelOpened();
        },
        onPanelSlide: (position) {
          // Actualizar la posición del panel para animar el BottomBar
          slideUpProvider.updatePanelPosition(position);
          // Si el panel está bajando (posición < 1), marcar que no está completamente abierto
          if (position < 1.0 && slideUpProvider.isPanelFullyOpen) {
            slideUpProvider.onPanelClosing();
          }
        },
        onPanelClosed: () {
          cleanSlideUp(slideUpProvider, true);
        },
        panelBuilder: () => _SlideUpContent(
          panelController: widget.panelController,
          scrollController: _panelScrollController,
        ),
        body: Stack(
          children: [
            Container(decoration: boxDecoration),
            // Efecto de partículas/decoración sutil
            _BackgroundDecoration(),
            _AppBar(
              title: widget.appBarTitle,
              leading: widget.appBarLeading,
              trailing: widget.appBarTrailing,
            ),
            _Body(child: widget.bodyContent),
          ],
        ),
      ),
    );
  }

  cleanSlideUp(SlideUpProvider slideUpProvider, [isListener = false]) {
    if (slideUpProvider.body != null) slideUpProvider.body = null;
    FocusManager.instance.primaryFocus?.unfocus();

    // Limpiar entidades en edición al cerrar el panel (solo si no se está abriendo un modal)
    if (!slideUpProvider.skipCleanOnClose) {
      context.read<JugadorProvider>().jugadorEditar = null;
      context.read<PartidaProvider>().partidaEditar = null;
    }
    slideUpProvider.resetSkipClean();

    slideUpProvider.closeSlideUp(controller: widget.panelController, isListener: isListener);
  }
}

// Decoración de fondo sutil
class _BackgroundDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CirclesPainter(),
        ),
      ),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Círculos decorativos sutiles
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.3),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      40,
      paint..color = Colors.white.withValues(alpha: 0.02),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppBar extends StatelessWidget {
  const _AppBar({Key? key, this.title, this.leading, this.trailing}) : super(key: key);

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: ResponsiveApp.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (leading != null)
              Container(
                margin: ResponsiveApp.only(right: 3),
                child: leading!,
              ),
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveApp.scaleText(18),
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            if (trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = topPadding + 65;

    return Column(
      children: [
        SizedBox(height: appBarHeight),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(ResponsiveApp.scaleWidth(50))),
              color: AppThemes.themeColor_1,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(ResponsiveApp.scaleWidth(50))),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideUpContent extends StatelessWidget {
  const _SlideUpContent({
    Key? key,
    required this.panelController,
    required this.scrollController,
  }) : super(key: key);

  final PanelController panelController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();
    ThemeProvider themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveApp.scaleWidth(24)),
          topRight: Radius.circular(ResponsiveApp.scaleWidth(24)),
        ),
        color: AppThemes.themeColor_2,
      ),
      child: Column(
        children: [
          // Handle del panel
          _PanelHandle(),
          // Contenido
          Expanded(
            child: Padding(
              padding: ResponsiveApp.only(right: 12, left: 12, bottom: 16),
              child: KeyedSubtree(
                key: ValueKey('body_${themeProvider.isDarkMode}'),
                child: SlideUpScrollController(
                  scrollController: scrollController,
                  child: slideUpProvider.body ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Handle del panel modernizado
class _PanelHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      padding: ResponsiveApp.symmetric(vertical: 12),
      child: Container(
        width: ResponsiveApp.scaleWidth(40),
        height: ResponsiveApp.scaleHeight(5),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(ResponsiveApp.scaleWidth(10)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
          ],
        ),
      ),
    );
  }
}

/// InheritedWidget para proporcionar el ScrollController del SlideUp a los widgets hijos
class SlideUpScrollController extends InheritedWidget {
  const SlideUpScrollController({
    Key? key,
    required this.scrollController,
    required Widget child,
  }) : super(key: key, child: child);

  final ScrollController scrollController;

  static ScrollController? of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SlideUpScrollController>();
    return result?.scrollController;
  }

  @override
  bool updateShouldNotify(SlideUpScrollController oldWidget) => scrollController != oldWidget.scrollController;
}

/// Mixin para widgets que necesitan scroll automático dentro del SlideUpPanel
/// Coordina el estado del panel con el scroll del ListView
mixin SlideUpAutoScrollMixin<T extends StatefulWidget> on State<T> {
  ScrollController? _autoScrollController;
  bool _scrollPending = false;
  int _retryCount = 0;
  static const int _maxRetries = 50; // Máximo ~1s de reintentos

  /// Obtiene el ScrollController del panel o usa el fallback proporcionado
  ScrollController getEffectiveController(BuildContext context, ScrollController fallback) {
    return SlideUpScrollController.of(context) ?? fallback;
  }

  /// Programa un scroll al final de la lista
  /// Se ejecuta cuando el panel está completamente abierto y el contenido está listo
  void scheduleScrollToBottom(BuildContext context, ScrollController controller) {
    // Cancelar cualquier scroll pendiente anterior
    cancelPendingScroll();

    _autoScrollController = controller;
    _scrollPending = true;
    _retryCount = 0;

    // Usar post frame callback para asegurar que el widget está construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollPending) return;

      final slideUpProvider = context.read<SlideUpProvider>();

      // Si el panel ya está abierto, ejecutar directamente con un pequeño delay
      if (slideUpProvider.isPanelFullyOpen) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _scrollPending) _executeScrollWhenReady();
        });
      } else {
        // Esperar a que el panel esté completamente abierto
        slideUpProvider.executeWhenPanelOpen(() {
          if (!mounted || !_scrollPending) return;
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _scrollPending) _executeScrollWhenReady();
          });
        });
      }
    });
  }

  /// Ejecuta el scroll cuando el controller tiene contenido
  void _executeScrollWhenReady() {
    if (!mounted || _autoScrollController == null || !_scrollPending) return;

    final controller = _autoScrollController!;

    // Verificar si el controller tiene posición y contenido
    if (!controller.hasClients) {
      _scheduleRetry();
      return;
    }

    final position = controller.position;

    // Verificar si el contenido está listo
    if (!position.hasContentDimensions || position.maxScrollExtent <= 0) {
      _scheduleRetry();
      return;
    }

    // Contenido listo, ejecutar scroll
    _scrollPending = false;
    _retryCount = 0;
    controller.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Programa un reintento con límite
  void _scheduleRetry() {
    if (!mounted || !_scrollPending) return;

    _retryCount++;
    if (_retryCount >= _maxRetries) {
      _scrollPending = false;
      _retryCount = 0;
      return;
    }

    Future.delayed(const Duration(milliseconds: 20), () {
      if (mounted && _scrollPending) _executeScrollWhenReady();
    });
  }

  /// Cancela cualquier scroll pendiente
  void cancelPendingScroll() {
    _scrollPending = false;
    _retryCount = 0;
    _autoScrollController = null;
  }
}
