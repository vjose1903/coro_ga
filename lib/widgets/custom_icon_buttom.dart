import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';

class IconSize {
  static const double min = 30;
  static const double max = 50;
}

class CustomIconButtom extends StatelessWidget {
  const CustomIconButtom(
      {Key? key,
      required this.icon,
      this.onTap,
      this.size = IconSize.max,
      this.iconSize = 30,
      this.splashColor = Colors.grey,
      this.backgroundColor = Colors.transparent,
      this.iconColor})
      : super(key: key);

  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Function? onTap;
  final double? size;
  final Color? splashColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Color myIconColor = iconColor ?? (AppThemes.currentTheme == "dark" ? Colors.white : Colors.black);

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
            child: Icon(icon, color: myIconColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}
