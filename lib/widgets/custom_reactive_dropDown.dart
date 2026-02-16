import 'package:flutter/material.dart';
import '../themes/app_themes.dart';
import '../utils/l10n_helper.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../helpers/helpers.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

class CustomReactiveDropDown extends StatelessWidget {
  const CustomReactiveDropDown({
    Key? key,
    required this.formControlName,
    required this.items,
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
    this.onChanged,
  }) : super(key: key);
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
  final List<DropdownMenuItem> items;
  final Function? onChanged;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder(
      formControlName: formControlName,
      builder: (context, control, child) {
        final value = control.value;
        final hasValue = value != null && value.toString().trim().isNotEmpty;
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
                style: child.style?.copyWith(
                  fontSize: TextScale.resolveSize(context, size: itemTextSize),
                ),
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

          return DefaultTextStyle.merge(
            style: TextStyle(fontSize: TextScale.resolveSize(context, size: itemTextSize)),
            child: child,
          );
        }

        final effectiveItems = items
            .map(
              (item) => DropdownMenuItem(
                value: item.value,
                enabled: item.enabled,
                child: scaleDropdownChild(item.child ?? const SizedBox.shrink()),
              ),
            )
            .toList();

        return ReactiveDropdownField<dynamic>(
            key: key,
            formControlName: formControlName,
            items: effectiveItems,
            autofocus: autoFocus!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: TextScale.resolveSize(context, size: itemTextSize),
              color: enabled
                  ? (Theme.of(context).textTheme.bodyLarge?.color ?? AppThemes.colorQuinto)
                  : AppThemes.labelInputDisabledColor,
            ),
            onChanged: (value) => onChanged != null ? onChanged!(value) : null,
            decoration: InputDecoration(
              label: labelText == null
                  ? null
                  : TextScale(
                      labelText!,
                      size: 14,
                      style: TextStyle(
                        color: enabled ? (hasValue ? AppThemes.colorQuinto : AppThemes.labelInputColor) : AppThemes.labelInputDisabledColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
              hint: hintText == null
                  ? null
                  : TextScale(
                      hintText!,
                      size: 13,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
              helper: helperText == null
                  ? null
                  : TextScale(
                      helperText!,
                      size: 12,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
              suffixIcon: innerRight == null ? null : IconScale(innerRight!),
              icon: innerLeft == null ? null : IconScale(innerLeft!),

              // FillColor --------
              fillColor: enabled ? AppThemes.inputColor : AppThemes.inputDisabledColor,

            ),
            showErrors: (control) => control.invalid && (control.touched || control.dirty),
            validationMessages: {
              'required': (error) => L10n.fieldRequired,
            });
      },
    );
  }
}
