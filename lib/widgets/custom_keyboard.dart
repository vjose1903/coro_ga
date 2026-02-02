import 'package:flutter/material.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';

enum KeyboardType { number }

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({super.key, required this.onChanged, required this.tipo, this.buttonHeight});
  final Function onChanged;
  final KeyboardType tipo;
  final double? buttonHeight;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Altura responsive: en pantallas pequeñas (<700px) reduce proporcionalmente
    final defaultHeight = screenHeight < 700 ? (screenHeight * 0.045).clamp(28.0, 38.0) : 38.0;
    final height = buttonHeight ?? defaultHeight;

    return Table(
      children: [
        TableRow(children: [_Tecla(label: '1', onChanged: (value) => onChanged(value), height: height), _Tecla(label: '2', onChanged: (value) => onChanged(value), height: height), _Tecla(label: '3', onChanged: (value) => onChanged(value), height: height)]),
        TableRow(children: [_Tecla(label: '4', onChanged: (value) => onChanged(value), height: height), _Tecla(label: '5', onChanged: (value) => onChanged(value), height: height), _Tecla(label: '6', onChanged: (value) => onChanged(value), height: height)]),
        TableRow(children: [_Tecla(label: '7', onChanged: (value) => onChanged(value), height: height), _Tecla(label: '8', onChanged: (value) => onChanged(value), height: height), _Tecla(label: '9', onChanged: (value) => onChanged(value), height: height)]),
        TableRow(children: [Container(), _Tecla(label: '0', onChanged: (value) => onChanged(value), height: height), _Tecla(label: 'DEL', icon: Icons.backspace_rounded, onChanged: (value) => onChanged(value), backgroundColor: Colors.transparent, height: height)]),
      ],
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla({
    super.key,
    required this.label,
    required this.onChanged,
    this.icon,
    this.backgroundColor,
    this.labelColor,
    this.height = 38,
  });

  final String? label;
  final Function onChanged;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? labelColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isTransparent = backgroundColor == Colors.transparent;
    final Color backColor = backgroundColor ?? (Preferences.isDarkMode ? const Color(0xff505050) : const Color(0xffFFFFFF));
    final margin = height < 34 ? 3.0 : 5.0;

    return Container(
      margin: EdgeInsets.all(margin),
      decoration: isTransparent
          ? null
          : BoxDecoration(
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
        height: height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(label),
            borderRadius: BorderRadius.circular(10),
            child: Center(child: _Simbolo(label: label, icon: icon, labelColor: labelColor, height: height)),
          ),
        ),
      ),
    );
  }
}

class _Simbolo extends StatelessWidget {
  const _Simbolo({super.key, this.label, this.icon, this.labelColor, this.height = 38});

  final String? label;
  final IconData? icon;
  final Color? labelColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color color = labelColor ?? (Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.8) : AppThemes.colorQuinto.withValues(alpha: 0.9));
    // Escalar tamaño basado en altura de tecla
    final iconSize = (height * 0.52).clamp(16.0, 20.0);
    final fontSize = (height * 0.45).clamp(14.0, 17.0);
    if (icon != null) return Icon(icon, size: iconSize, color: color);
    return Text(
      label!,
      style: TextStyle(fontFamily: 'Poppins', fontSize: fontSize, color: color),
    );
  }
}
