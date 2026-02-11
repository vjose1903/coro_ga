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
    super.key,
    required this.builder,
    this.wideThreshold = 700,
    this.useMediaQuery = false,
  });

  final double wideThreshold;
  final bool useMediaQuery;
  final Widget Function(BuildContext context, BoxConstraints constraints, ResponsiveLayoutInfo info) builder;

  static ResponsiveLayoutInfo? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ResponsiveLayoutScope>()?.info;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.of(context).size;
        final maxWidth = useMediaQuery ? mediaSize.width : constraints.maxWidth;
        final maxHeight = useMediaQuery ? mediaSize.height : constraints.maxHeight;
        final isLandscape = maxWidth > maxHeight;
        final isWide = maxWidth >= wideThreshold;
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
            builder: (scopedContext) => builder(scopedContext, constraints, info),
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
