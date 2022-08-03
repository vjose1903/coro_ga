import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveInput extends StatelessWidget {
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

  final int? maxLength;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField(
        key: key,
        formControlName: formControlName,
        autofocus: autoFocus!,
        keyboardType: inputType,
        obscureText: obscureText,
        textCapitalization: textCapitalization!,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          suffixIcon: innerRight == null ? null : Icon(innerRight),
          icon: innerLeft == null ? null : Icon(innerLeft),

          // FillColor --------
          fillColor: enabled ? AppThemes.inputColor : AppThemes.inputDisabledColor,

          // Labels -----------
          labelStyle: TextStyle(color: enabled ? AppThemes.labelInputColor : AppThemes.labelInputDisabledColor, fontFamily: 'Poppins'),
          floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
            final Color? color = states.contains(MaterialState.error)
                ? enabled
                    ? Colors.red[900]
                    : Colors.red[900]!.withOpacity(0.6)
                : enabled
                    ? AppThemes.colorQuinto
                    : AppThemes.colorQuinto.withOpacity(0.6);
            return TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
          }),
        ),
        showErrors: (control) => control.invalid && (control.touched || control.dirty),
        validationMessages: (control) => {
              'required': "Campo requerido.",
            });
  }
}
