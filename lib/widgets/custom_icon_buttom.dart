import 'package:flutter/material.dart';
import '../shared_preferences/preferences.dart';
import 'icon_scale.dart';

class IconSize {
  static const double xMin = 20;
  static const double min = 30;
  static const double medium = 40;
  static const double max = 50;
}

class CustomIconButtom extends StatelessWidget {
  const CustomIconButtom({super.key, required this.icon, this.onTap, this.size = IconSize.max, this.iconSize = 30, this.splashColor = Colors.grey, this.backgroundColor = Colors.transparent, this.iconColor});

  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Function? onTap;
  final double? size;
  final Color? splashColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color myIconColor = iconColor ?? (Preferences.isDarkMode ? Colors.white : Colors.black);

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          splashColor: splashColor,
          onTap: () => onTap != null ? onTap!() : null,
          child: SizedBox(
            width: size,
            height: size,
            child: IconScale(icon, color: myIconColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}
