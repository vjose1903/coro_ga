import 'package:flutter/material.dart';
import 'icon_scale.dart';

class IconRounded extends StatelessWidget {
  const IconRounded({required this.icon, super.key, this.iconColor = Colors.grey, this.iconSize = 15, this.backgroundColor, this.marginLeft = 0, this.marginRight = 0});

  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final Color? backgroundColor;
  final double? marginLeft;
  final double? marginRight;

  @override
  Widget build(BuildContext context) {
    return Container(margin: EdgeInsets.only(left: marginLeft!, right: marginRight!), decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: backgroundColor), child: Padding(padding: const EdgeInsets.all(3), child: Center(child: IconScale(icon, size: iconSize, color: iconColor))));
  }
}
