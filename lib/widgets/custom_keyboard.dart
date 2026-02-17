import 'package:flutter/material.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import 'icon_scale.dart';
import 'text_scale.dart';

enum KeyboardType { number }

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({
    super.key,
    required this.onChanged,
    required this.tipo,
    required this.useLandscapeLayout,
    required this.isWide,
  });
  final Function onChanged;
  final KeyboardType tipo;
  final bool useLandscapeLayout;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final screenHeight = size.height;
    final isSmallDevice = shortestSide < 360 || screenHeight < 700;

    // Combina altura disponible + densidad del dispositivo.
    final baseHeight = (screenHeight * 0.052).clamp(30.0, 40.0);
    final compactHeight = (screenHeight * 0.046).clamp(28.0, 36.0);
    final keyboardBaseHeight = isSmallDevice ? compactHeight : baseHeight;

    final orientationAdjustedHeight = useLandscapeLayout ? (isWide ? keyboardBaseHeight : keyboardBaseHeight + 4) : keyboardBaseHeight;
    final height = orientationAdjustedHeight.clamp(isSmallDevice ? 28.0 : 30.0, isSmallDevice ? 36.0 : 42.0);

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
    if (icon != null) return IconScale(icon!, size: iconSize, color: color);
    return TextScale(
      label!,
      size: fontSize,
      style: TextStyle(fontFamily: 'Poppins', color: color),
    );
  }
}
