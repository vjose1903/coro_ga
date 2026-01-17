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
    final bool isTransparent = backgroundColor == Colors.transparent;
    Color backColor = backgroundColor ?? (Preferences.isDarkMode ? const Color(0xff505050) : const Color(0xffFFFFFF));
    
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: isTransparent ? null : BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // Sombra oscura sutil
          BoxShadow(
            color: Colors.black.withValues(alpha: Preferences.isDarkMode ? 0.15 : 0.08),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
          // Sombra clara sutil
          BoxShadow(
            color: Colors.white.withValues(alpha: Preferences.isDarkMode ? 0.08 : 0.6),
            blurRadius: 3,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: SizedBox(
        height: 38,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(label),
            borderRadius: BorderRadius.circular(10),
            child: Center(child: _Simbolo(label: label, icon: icon, labelColor: labelColor)),
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
