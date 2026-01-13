import 'package:flutter/material.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';

enum KeyboardType { number }

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({Key? key, required this.onChanged, required this.tipo}) : super(key: key);
  final Function onChanged;
  final KeyboardType tipo;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(children: [
          _Tecla(label: "1", onChanged: (value) => onChanged(value)),
          _Tecla(label: "2", onChanged: (value) => onChanged(value)),
          _Tecla(label: "3", onChanged: (value) => onChanged(value))
        ]),
        TableRow(children: [
          _Tecla(label: "4", onChanged: (value) => onChanged(value)),
          _Tecla(label: "5", onChanged: (value) => onChanged(value)),
          _Tecla(label: "6", onChanged: (value) => onChanged(value))
        ]),
        TableRow(children: [
          _Tecla(label: "7", onChanged: (value) => onChanged(value)),
          _Tecla(label: "8", onChanged: (value) => onChanged(value)),
          _Tecla(label: "9", onChanged: (value) => onChanged(value))
        ]),
        TableRow(children: [
          Container(),
          _Tecla(label: "0", onChanged: (value) => onChanged(value)),
          _Tecla(label: "DEL", icon: Icons.backspace_rounded, onChanged: (value) => onChanged(value), backgroundColor: Colors.transparent)
        ]),
      ],
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla({Key? key, required this.label, required this.onChanged, this.icon, this.backgroundColor, this.labelColor}) : super(key: key);

  final String? label;
  final Function onChanged;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    Color backColor = backgroundColor ?? (Preferences.isDarkMode ? const Color(0xff727272) : const Color(0xffFFFFFF));
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          height: 35,
          child: Material(
            color: backColor,
            child: InkWell(
              onTap: () => onChanged(label),
              child: Center(child: _Simbolo(label: label, icon: icon, labelColor: labelColor)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Simbolo extends StatelessWidget {
  const _Simbolo({Key? key, this.label, this.icon, this.labelColor}) : super(key: key);

  final String? label;
  final IconData? icon;
  final Color? labelColor;
  @override
  Widget build(BuildContext context) {
    Color color = labelColor ?? (Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.8) : AppThemes.colorQuinto.withValues(alpha: 0.9));
    if (icon != null) {
      return Icon(icon, size: 20, color: color);
    } else {
      return Text(label!, style: TextStyle(fontFamily: 'Poppins', fontSize: 17, color: color));
    }
  }
}
