import 'package:flutter/material.dart';

class ExpandedButtom extends StatelessWidget {
  const ExpandedButtom({
    Key? key,
    required this.label,
    this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 15,
  }) : super(key: key);

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
            child: Text(label, style: TextStyle(fontFamily: "Poppins", fontSize: fontSize, color: textColor), textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
  }
}
