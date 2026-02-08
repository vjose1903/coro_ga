import 'package:flutter/material.dart';
import '../themes/app_themes.dart';
import '../utils/l10n_helper.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../helpers/helpers.dart';
import 'text_scale.dart';

class CustomReactiveInput extends StatelessWidget {
  const CustomReactiveInput({
    Key? key,
    required this.formControlName,
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
  final FocusNode? focusNode;

  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder(
      formControlName: formControlName,
      builder: (context, control, child) {
        final value = control.value;
        final hasValue = value != null && value.toString().trim().isNotEmpty;

        return ReactiveTextField(
            key: key,
            formControlName: formControlName,
            focusNode: focusNode,
            autofocus: autoFocus!,
            keyboardType: inputType,
            obscureText: obscureText,
            textCapitalization: textCapitalization!,
            maxLength: maxLength,
            readOnly: !enabled,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: TextScale.resolveSize(context, size: 16),
              color: enabled
                  ? (Theme.of(context).textTheme.bodyLarge?.color ?? AppThemes.colorQuinto)
                  : AppThemes.labelInputDisabledColor,
            ),
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
              suffixIcon: innerRight == null ? null : Icon(innerRight),
              icon: innerLeft == null ? null : Icon(innerLeft),

              // FillColor --------
              fillColor: enabled ? AppThemes.inputColor : AppThemes.inputDisabledColor,

            ),
            showErrors: (control) => control.invalid && (control.touched || control.dirty),
            validationMessages: {
              'required': (error) => L10n.fieldRequired,
              'min': (error) => L10n.minValue((error as Map)['min'].toString()),
            });
      },
    );
  }
}
