import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../themes/app_themes.dart';
import '../utils/l10n_helper.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

class CustomReactiveInput extends StatefulWidget {
  const CustomReactiveInput({
    required this.formControlName,
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
  final int? maxLength;

  @override
  State<CustomReactiveInput> createState() => _CustomReactiveInputState();
}

class _CustomReactiveInputState extends State<CustomReactiveInput> {
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
  void didUpdateWidget(covariant CustomReactiveInput oldWidget) {
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

        return ReactiveTextField(
            key: widget.key,
            formControlName: widget.formControlName,
            focusNode: _effectiveFocusNode,
            autofocus: widget.autoFocus!,
            keyboardType: widget.inputType,
            obscureText: widget.obscureText,
            textCapitalization: widget.textCapitalization!,
            maxLength: widget.maxLength,
            readOnly: !widget.enabled,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: TextScale.resolveSize(context, size: 16),
              color: widget.enabled ? (Theme.of(context).textTheme.bodyLarge?.color ?? AppThemes.colorQuinto) : AppThemes.labelInputDisabledColor,
            ),
            decoration: InputDecoration(
              isDense: isLandscape,
              contentPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 8 : 10, vertical: isLandscape ? 4 : 5),
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
              'min': (error) => L10n.minValue((error as Map)['min'].toString()),
            });
      },
    );
  }
}
