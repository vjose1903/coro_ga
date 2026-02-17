import 'package:flutter/material.dart';
import 'text_scale.dart';

class ExpandedButtom extends StatelessWidget {
  const ExpandedButtom({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    super.key,
    this.onTap,
    this.fontSize = 15,
  });

  final String label;
  final Function? onTap;
  final Color? backgroundColor;
  final Color textColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onTap: () => onTap != null ? onTap!() : null,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: TextScale(label, style: TextStyle(fontFamily: 'Poppins', fontSize: fontSize, color: textColor), textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
  }
}
