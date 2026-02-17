import 'package:flutter/material.dart';

class ResponsiveLayoutInfo {
  const ResponsiveLayoutInfo({
    required this.constraints,
    required this.isLandscape,
    required this.isWide,
    required this.aspectRatio,
    required this.useLandscapeLayout,
  });

  final BoxConstraints constraints;
  final bool isLandscape;
  final bool isWide;
  final double aspectRatio;
  final bool useLandscapeLayout;
}

class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    required this.builder,
    super.key,
    this.wideThreshold = 600,
    this.useMediaQuery = false,
  });

  final double wideThreshold;
  final bool useMediaQuery;
  final Widget Function(BuildContext context, BoxConstraints constraints,
      ResponsiveLayoutInfo info) builder;

  static ResponsiveLayoutInfo? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ResponsiveLayoutScope>()
        ?.info;
  }

  static bool resolveIsWide(BuildContext context,
      {double wideThreshold = 600}) {
    return MediaQuery.sizeOf(context).shortestSide >= wideThreshold;
  }

  static bool resolveUseLandscapeLayout(BuildContext context,
      {double wideThreshold = 600}) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;
    return isLandscape || resolveIsWide(context, wideThreshold: wideThreshold);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.of(context).size;
        final maxWidth = useMediaQuery ? mediaSize.width : constraints.maxWidth;
        final maxHeight =
            useMediaQuery ? mediaSize.height : constraints.maxHeight;
        // `isWide` debe seguir la misma lógica global que TextScale/IconScale:
        // se determina por el tamaño real del dispositivo, no por constraints locales.
        final shortestSide = mediaSize.shortestSide;
        final isLandscape = maxWidth > maxHeight;
        final isWide = shortestSide >= wideThreshold;
        final aspectRatio = maxHeight == 0 ? 0.0 : maxWidth / maxHeight;
        final useLandscapeLayout = isLandscape || isWide;

        final info = ResponsiveLayoutInfo(
          constraints: constraints,
          isLandscape: isLandscape,
          isWide: isWide,
          aspectRatio: aspectRatio,
          useLandscapeLayout: useLandscapeLayout,
        );

        return _ResponsiveLayoutScope(
          info: info,
          child: Builder(
            builder: (scopedContext) =>
                builder(scopedContext, constraints, info),
          ),
        );
      },
    );
  }
}

class _ResponsiveLayoutScope extends InheritedWidget {
  const _ResponsiveLayoutScope({
    required this.info,
    required super.child,
  });

  final ResponsiveLayoutInfo info;

  @override
  bool updateShouldNotify(_ResponsiveLayoutScope oldWidget) {
    return oldWidget.info.useLandscapeLayout != info.useLandscapeLayout ||
        oldWidget.info.isLandscape != info.isLandscape ||
        oldWidget.info.isWide != info.isWide ||
        oldWidget.info.aspectRatio != info.aspectRatio ||
        oldWidget.info.constraints != info.constraints;
  }
}
