import 'package:flutter/material.dart';

class Orden {
  static const String primeroIcono = 'primeroIcono';
  static const String primeroLabel = 'primeroLabel';
}

class LabelWithIcon extends StatelessWidget {
  const LabelWithIcon({
    Key? key,
    this.maxSize = 0,
    this.orden = Orden.primeroLabel,
    required this.label,
    required this.icon,
    this.labelColor = Colors.grey,
    this.iconColor = Colors.grey,
    this.labelSize = 17,
    this.iconSize = 15,
  }) : super(key: key);

  final String? orden;
  final double? maxSize;

  final String label;
  final Color? labelColor;
  final double? labelSize;

  final IconData icon;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (orden == Orden.primeroIcono) Container(margin: const EdgeInsets.only(right: 3), child: Icon(icon, size: iconSize!, color: iconColor)),

        //
        if (maxSize != null)
          ConstrainedBox(constraints: BoxConstraints(maxWidth: maxSize!), child: _Label(label: label, labelColor: labelColor, labelSize: labelSize))
        else
          _Label(label: label, labelColor: labelColor, labelSize: labelSize),
        //

        if (orden == Orden.primeroLabel) Container(margin: const EdgeInsets.only(left: 15), child: Icon(icon, size: iconSize!, color: iconColor))
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({Key? key, required this.label, required this.labelColor, required this.labelSize}) : super(key: key);

  final String label;
  final Color? labelColor;
  final double? labelSize;

  @override
  Widget build(BuildContext context) {
    return Text(label, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: labelColor, fontSize: labelSize!));
  }
}
