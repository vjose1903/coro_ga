import 'package:flutter/material.dart';
import 'package:game_score/widgets/widgets.dart';

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
    this.iconBackgroundColor,
  }) : super(key: key);

  final String? orden;
  final double? maxSize;

  final String label;
  final Color? labelColor;
  final double? labelSize;

  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (orden == Orden.primeroIcono)
          _Icon(icon: icon, iconSize: iconSize!, iconColor: iconColor, backgroundColor: iconBackgroundColor, orden: orden),

        //
        if (maxSize != 0)
          ConstrainedBox(constraints: BoxConstraints(maxWidth: maxSize!), child: _Label(label: label, labelColor: labelColor, labelSize: labelSize))
        else
          _Label(label: label, labelColor: labelColor, labelSize: labelSize),
        //

        if (orden == Orden.primeroLabel)
          _Icon(icon: icon, iconSize: iconSize!, iconColor: iconColor, backgroundColor: iconBackgroundColor, orden: orden)
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
    return Text(label,
        overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: labelColor, fontSize: labelSize!, fontFamily: 'Poppins'));
  }
}

class _Icon extends StatelessWidget {
  const _Icon({Key? key, required this.icon, required this.iconColor, required this.iconSize, this.backgroundColor, this.orden}) : super(key: key);

  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? iconSize;
  final String? orden;

  @override
  Widget build(BuildContext context) {
    final double _right = orden == Orden.primeroIcono ? 5 : 0;
    final double _left = orden == Orden.primeroLabel ? 5 : 0;

    return Container(
      margin: EdgeInsets.only(left: _left, right: _right),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
              color: backgroundColor,
              child: Padding(padding: const EdgeInsets.all(3), child: Center(child: Icon(icon, size: iconSize!, color: iconColor))))),
    );
  }
}
