import 'package:flutter/material.dart';

import '../helpers/helpers.dart';

class IconScale extends StatelessWidget {
  const IconScale(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.fill,
    this.grade,
    this.weight,
    this.opticalSize,
    this.shadows,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final double? fill;
  final double? grade;
  final double? weight;
  final double? opticalSize;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final shortestSide = mediaSize.shortestSide;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final isLargeDevice = shortestSide >= 600;
    final landscapePhoneBoost = isLandscape && !isLargeDevice ? 0.6 : 0.5;
    final portraitBias = isLandscape ? 0.9 : 0.8;
    
    debugPrint('isLargeDevice ${isLargeDevice}' );

    final resolvedSize = size ?? 24.0;
    final scaledBase = ResponsiveApp.scaleWidth(resolvedSize) * portraitBias * landscapePhoneBoost;
    final minSize = ResponsiveApp.scaleWidth(resolvedSize * 0.9) * portraitBias * landscapePhoneBoost;
    final maxSize = ResponsiveApp.scaleWidth(resolvedSize * 1.0) * portraitBias * landscapePhoneBoost;
    final clampedSize = _clampSize(scaledBase, minSize, maxSize);

    return Icon(
      icon,
      key: key,
      size: clampedSize,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      fill: fill,
      grade: grade,
      weight: weight,
      opticalSize: opticalSize,
      shadows: shadows,
    );
  }

  double _clampSize(double size, double min, double max) {
    if (size < min) return min;
    if (size > max) return max;
    return size;
  }
}
