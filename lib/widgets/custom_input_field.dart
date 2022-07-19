import 'package:flutter/material.dart';

class CustomInputField<T> extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? innerLeft;
  final IconData? innerRight;
  final TextInputType? inputType;
  final bool obscureText;

  final Function? validators;
  final Function initialValueFn;
  final Function onChanged;

  const CustomInputField({
    Key? key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.innerLeft,
    this.innerRight,
    this.inputType,
    this.obscureText = false,
    this.validators,
    required this.initialValueFn,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
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
        // prefixIcon: Icon(Icons.verified_user_outlined),
        icon: innerLeft == null ? null : Icon(innerLeft),
      ),
    );
  }
}
