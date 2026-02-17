import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../themes/app_themes.dart';
import '../utils/l10n_helper.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

class CustomReactiveDropDown extends StatefulWidget {
  const CustomReactiveDropDown({
    required this.formControlName,
    required this.items,
    super.key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.innerLeft,
    this.innerRight,
    this.inputType,
    this.obscureText = false,
    this.enabled = true,
    this.autoFocus = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onChanged,
  });

  final String formControlName;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? innerLeft;
  final IconData? innerRight;
  final TextInputType? inputType;
  final bool obscureText;
  final bool enabled;
  final bool? autoFocus;
  final TextCapitalization? textCapitalization;
  final FocusNode? focusNode;
  final List<DropdownMenuItem> items;
  final Function? onChanged;
  final int? maxLength;

  @override
  State<CustomReactiveDropDown> createState() => _CustomReactiveDropDownState();
}

class _CustomReactiveDropDownState extends State<CustomReactiveDropDown> {
  late final FocusNode _internalFocusNode = FocusNode();

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CustomReactiveDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode).removeListener(_onFocusChange);
      _effectiveFocusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder(
      formControlName: widget.formControlName,
      builder: (context, control, child) {
        final value = control.value;
        final hasValue = value != null && value.toString().trim().isNotEmpty;
        final hasLabelTopPadding = hasValue || _effectiveFocusNode.hasFocus;
        final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
        const itemTextSize = 16.0;

        Widget scaleDropdownChild(Widget child) {
          if (child is TextScale) {
            if (child.textSpan != null) {
              return TextScale.rich(
                child.textSpan!,
                size: itemTextSize,
                style: child.style,
                strutStyle: child.strutStyle,
                textAlign: child.textAlign,
                textDirection: child.textDirection,
                locale: child.locale,
                softWrap: child.softWrap,
                overflow: child.overflow,
                textScaler: child.textScaler,
                maxLines: child.maxLines,
                semanticsLabel: child.semanticsLabel,
                textWidthBasis: child.textWidthBasis,
                textHeightBehavior: child.textHeightBehavior,
                selectionColor: child.selectionColor,
              );
            }
            return TextScale(
              child.data ?? '',
              size: itemTextSize,
              style: child.style,
              strutStyle: child.strutStyle,
              textAlign: child.textAlign,
              textDirection: child.textDirection,
              locale: child.locale,
              softWrap: child.softWrap,
              overflow: child.overflow,
              textScaler: child.textScaler,
              maxLines: child.maxLines,
              semanticsLabel: child.semanticsLabel,
              textWidthBasis: child.textWidthBasis,
              textHeightBehavior: child.textHeightBehavior,
              selectionColor: child.selectionColor,
            );
          }

          if (child is Text) {
            if (child.textSpan != null) {
              final span = child.textSpan;
              if (span is TextSpan) {
                return TextScale.rich(
                  span,
                  size: itemTextSize,
                  style: child.style,
                  strutStyle: child.strutStyle,
                  textAlign: child.textAlign,
                  textDirection: child.textDirection,
                  locale: child.locale,
                  softWrap: child.softWrap,
                  overflow: child.overflow,
                  textScaler: child.textScaler,
                  maxLines: child.maxLines,
                  semanticsLabel: child.semanticsLabel,
                  textWidthBasis: child.textWidthBasis,
                  textHeightBehavior: child.textHeightBehavior,
                  selectionColor: child.selectionColor,
                );
              }
              return Text.rich(
                span!,
                style: child.style?.copyWith(fontSize: TextScale.resolveSize(context, size: itemTextSize)),
                strutStyle: child.strutStyle,
                textAlign: child.textAlign,
                textDirection: child.textDirection,
                locale: child.locale,
                softWrap: child.softWrap,
                overflow: child.overflow,
                textScaler: child.textScaler,
                maxLines: child.maxLines,
                semanticsLabel: child.semanticsLabel,
                textWidthBasis: child.textWidthBasis,
                textHeightBehavior: child.textHeightBehavior,
                selectionColor: child.selectionColor,
              );
            }
            return TextScale(
              child.data ?? '',
              size: itemTextSize,
              style: child.style,
              strutStyle: child.strutStyle,
              textAlign: child.textAlign,
              textDirection: child.textDirection,
              locale: child.locale,
              softWrap: child.softWrap,
              overflow: child.overflow,
              textScaler: child.textScaler,
              maxLines: child.maxLines,
              semanticsLabel: child.semanticsLabel,
              textWidthBasis: child.textWidthBasis,
              textHeightBehavior: child.textHeightBehavior,
              selectionColor: child.selectionColor,
            );
          }

          return DefaultTextStyle.merge(style: TextStyle(fontSize: TextScale.resolveSize(context, size: itemTextSize)), child: child);
        }

        final effectiveItems = widget.items
            .map(
              (item) => DropdownMenuItem(
                value: item.value,
                enabled: item.enabled,
                child: scaleDropdownChild(item.child),
              ),
            )
            .toList();

        return ReactiveDropdownField<dynamic>(
            key: widget.key,
            formControlName: widget.formControlName,
            focusNode: _effectiveFocusNode,
            items: effectiveItems,
            autofocus: widget.autoFocus!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: TextScale.resolveSize(context, size: itemTextSize),
              color: widget.enabled ? (Theme.of(context).textTheme.bodyLarge?.color ?? AppThemes.colorQuinto) : AppThemes.labelInputDisabledColor,
            ),
            onChanged: (value) => widget.onChanged != null ? widget.onChanged!(value) : null,
            decoration: InputDecoration(
              isDense: isLandscape,
              contentPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 8 : 10, vertical: isLandscape ? 1 : 5),
              label: widget.labelText == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(top: hasLabelTopPadding ? 5 : 0),
                      child: TextScale(
                        widget.labelText!,
                        size: 14,
                        style: TextStyle(
                          color: widget.enabled ? (hasValue ? AppThemes.colorQuinto : AppThemes.labelInputColor) : AppThemes.labelInputDisabledColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
              hint: widget.hintText == null
                  ? null
                  : TextScale(
                      widget.hintText!,
                      size: 13,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
              helper: widget.helperText == null
                  ? null
                  : TextScale(
                      widget.helperText!,
                      size: 12,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
              suffixIcon: widget.innerRight == null ? null : IconScale(widget.innerRight!),
              icon: widget.innerLeft == null ? null : IconScale(widget.innerLeft!),

              // FillColor --------
              fillColor: widget.enabled ? AppThemes.inputColor : AppThemes.inputDisabledColor,
            ),
            showErrors: (control) => control.invalid && (control.touched || control.dirty),
            validationMessages: {
              'required': (error) => L10n.fieldRequired,
            });
      },
    );
  }
}
