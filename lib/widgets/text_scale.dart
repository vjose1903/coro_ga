import 'package:flutter/material.dart';

import '../helpers/helpers.dart';
import 'responsive_layout_builder.dart';

class TextScale extends StatelessWidget {
  static double resolveSize(BuildContext context, {double? size, TextStyle? style}) {
    final isLandscapeLayout = ResponsiveLayoutBuilder.maybeOf(context)?.useLandscapeLayout ?? ResponsiveLayoutBuilder.resolveUseLandscapeLayout(context);
    final isLargeDevice = ResponsiveLayoutBuilder.resolveIsWide(context);
    final landscapePhoneBoost = isLandscapeLayout && !isLargeDevice ? 1.7 : 1.0;
    final portraitBias = isLandscapeLayout ? 1.0 : 0.95;
    final maxFactor = isLargeDevice ? 1.05 : 1.25;

    final resolvedBaseSize = size ?? style?.fontSize ?? 14.0;
    final scaledBase = ResponsiveApp.scaleText(resolvedBaseSize) * portraitBias * landscapePhoneBoost;
    final minSize = ResponsiveApp.scaleText(resolvedBaseSize * 0.95) * portraitBias * landscapePhoneBoost;
    final maxSize = ResponsiveApp.scaleText(resolvedBaseSize * maxFactor) * portraitBias * landscapePhoneBoost;
    return _clampFontSizeStatic(scaledBase, minSize, maxSize);
  }

  const TextScale(
    this.data, {
    super.key,
    this.size,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const TextScale.rich(
    this.textSpan, {
    super.key,
    this.size,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final TextSpan? textSpan;
  final double? size;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final clampedSize = resolveSize(context, size: size, style: style);

    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: clampedSize,
    );

    if (textSpan != null) {
      return Text.rich(
        textSpan!,
        key: key,
        style: effectiveStyle,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return Text(
      data ?? '',
      key: key,
      style: effectiveStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  double _clampFontSize(double size, double min, double max) {
    if (size < min) return min;
    if (size > max) return max;
    return size;
  }

  static double _clampFontSizeStatic(double size, double min, double max) {
    if (size < min) return min;
    if (size > max) return max;
    return size;
  }
}
