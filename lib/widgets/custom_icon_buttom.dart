import 'package:flutter/material.dart';
import 'package:game_score/shared_preferences/preferences.dart';

class CustomIconButtom extends StatelessWidget {
  const CustomIconButtom(
      {Key? key,
      required this.icon,
      this.onTap,
      this.splashColor = Colors.grey,
      this.backgroundColor = Colors.transparent,
      this.iconColor,
      required this.tooltip})
      : super(key: key);

  final String tooltip;
  final IconData icon;
  final Color? iconColor;
  final Function? onTap;
  final Color? splashColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Color myIconColor = iconColor ?? (Preferences.isDarkMode ? Colors.white : Colors.black);

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          splashColor: splashColor,
          child: IconButton(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 40, maxHeight: 40, maxWidth: 40),
              padding: const EdgeInsets.all(0),
              tooltip: tooltip,
              onPressed: () => onTap != null ? onTap!() : null,
              icon: Icon(icon, color: myIconColor, size: 25)),
        ),
      ),
    );
  }
}
