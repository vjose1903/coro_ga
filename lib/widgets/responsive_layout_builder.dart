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

        return builder(
          context,
          constraints,
          ResponsiveLayoutInfo(
            constraints: constraints,
            isLandscape: isLandscape,
            isWide: isWide,
            aspectRatio: aspectRatio,
            useLandscapeLayout: useLandscapeLayout,
          ),
        );
      },
    );
  }
}
