import 'package:flutter/material.dart';
import '../themes/app_themes.dart';
import '../utils/l10n_helper.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../helpers/helpers.dart';

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
    return ReactiveDropdownField<dynamic>(
        key: key,
        formControlName: 'tipo',
        items: items,
        autofocus: autoFocus!,
        onChanged: (value) => onChanged != null ? onChanged!(value) : null,
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
          floatingLabelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
            final Color? color = states.contains(WidgetState.error)
                ? enabled
                    ? Colors.red[900]
                    : Colors.red[900]!.withValues(alpha: 0.6)
                : enabled
                    ? AppThemes.colorQuinto
                    : AppThemes.colorQuinto.withValues(alpha: 0.6);
            return TextStyle(
              color: color,
              fontSize: ResponsiveApp.scaleText(15),
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            );
          }),
        ),
        showErrors: (control) => control.invalid && (control.touched || control.dirty),
        validationMessages: {
          'required': (error) => L10n.fieldRequired,
        });
  }
}
