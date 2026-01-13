import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';

class CustomInputField<T> extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? innerLeft;
  final IconData? innerRight;
  final TextInputType? inputType;
  final bool obscureText;
  final bool enabled;

  final Function? validators;
  final Function initialValueFn;
  final Function onChanged;

  final TextEditingController? controller;

  const CustomInputField({
    Key? key,
    required this.initialValueFn,
    required this.onChanged,
    this.hintText,
    this.labelText,
    this.helperText,
    this.innerLeft,
    this.innerRight,
    this.inputType,
    this.obscureText = false,
    this.validators,
    this.controller,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      enabled: enabled,
      controller: controller,
      autofocus: false,
      initialValue: initialValueFn(),
      textCapitalization: TextCapitalization.words,
      keyboardType: inputType,
      obscureText: obscureText,
      onChanged: (value) => onChanged(value),
      validator: (value) => validators != null ? validators!(value) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        helperText: helperText,
        suffixIcon: innerRight == null ? null : Icon(innerRight),
        icon: innerLeft == null ? null : Icon(innerLeft),

        // FillColor --------
        fillColor: enabled ? AppThemes.inputColor : AppThemes.inputDisabledColor,

        // Labels -----------
        labelStyle: TextStyle(color: enabled ? AppThemes.labelInputColor : AppThemes.labelInputDisabledColor, fontFamily: 'Poppins'),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
          final Color? color = states.contains(WidgetState.error) ? enabled ? Colors.red[900] : Colors.red[900]!.withOpacity(0.6) : enabled ? AppThemes.colorQuinto : AppThemes.colorQuinto.withOpacity(0.6);
          return TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
          
        }),
      ),
    );
  }
}
