import 'dart:io';
import '../helpers/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';

enum DialogType { error, success, warning, info, custom }

class CustomActionsButtons {

  factory CustomActionsButtons.cancelButton(Map<String, dynamic> json) =>
      CustomActionsButtons(
        label: json["label"] ?? "Cancelar",
        onTap: json["onTap"] ?? () {},
        textColor: json["textColor"],
        isDestructive: true,
      );

  factory CustomActionsButtons.aceptarButton(Map<String, dynamic> json) =>
      CustomActionsButtons(
        label: json["label"] ?? "Aceptar",
        onTap: json["onTap"] ?? () {},
        textColor: json["textColor"],
        isPrimary: true,
      );
  CustomActionsButtons({
    required this.label, this.textColor,
    this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final Function? onTap;
  final Color? textColor;
  final bool isPrimary;
  final bool isDestructive;

  static Color? defaultTextColor = Preferences.isDarkMode
      ? Colors.white.withValues(alpha: 0.7)
      : Colors.blueGrey[600]!.withValues(alpha: 0.7);
}

class CustomAlertDialog {
  static show(
    BuildContext context, {
    required String menssage,
    required String title,
    Widget? body,
    DialogType? dialogType,
    List<CustomActionsButtons>? buttonsList,
  }) {
    if (Platform.isAndroid) {
      displayDialogAndroid(
          context: context,
          menssage: menssage,
          title: title,
          dialogType: dialogType,
          body: body,
          buttonsList: buttonsList);
    } else {
      displayDialogIOs(
          context: context,
          menssage: menssage,
          title: title,
          dialogType: dialogType,
          body: body,
          buttonsList: buttonsList);
    }
  }

  static void displayDialogAndroid({
    required BuildContext context,
    required String title,
    required String menssage,
    Widget? body,
    List<CustomActionsButtons>? buttonsList,
    DialogType? dialogType,
  }) {
    final isDark = Preferences.isDarkMode;

    showDialog(
      barrierDismissible: buttonsList == null || buttonsList.isEmpty,
      context: context,
      builder: (buildContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: isDark ? AppThemes.themeColor_2 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con icono
                _DialogHeader(title: title, dialogType: dialogType),
                // Contenido
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: DialogBody(
                    dialogType: dialogType,
                    menssage: menssage,
                    body: body,
                  ),
                ),
                // Botones
                if (buttonsList != null && buttonsList.isNotEmpty)
                  _DialogActions(buttons: buttonsList),
              ],
            ),
          ),
        );
      },
    );
  }

  static void displayDialogIOs({
    required BuildContext context,
    required String title,
    required String menssage,
    Widget? body,
    List<CustomActionsButtons>? buttonsList,
    DialogType? dialogType,
  }) {
    showCupertinoDialog(
      barrierDismissible: buttonsList == null || buttonsList.isEmpty,
      context: context,
      builder: (buildContext) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dialogType != null) ...[
                  _getIconWidget(dialogType, size: 22),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: _makeActionsButtonsIOS(buttonsList),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DialogBody(
              dialogType: dialogType,
              menssage: menssage,
              body: body,
            ),
          ),
        );
      },
    );
  }

  static Widget _getIconWidget(DialogType? type, {double size = 28}) {
    if (type == null) return const SizedBox.shrink();

    IconData iconData;
    List<Color> gradientColors;

    switch (type) {
      case DialogType.error:
        iconData = FontAwesomeIcons.circleXmark;
        gradientColors = [const Color(0xFFEF5350), const Color(0xFFE53935)];
        break;
      case DialogType.success:
        iconData = FontAwesomeIcons.circleCheck;
        gradientColors = [const Color(0xFF66BB6A), const Color(0xFF43A047)];
        break;
      case DialogType.warning:
        iconData = FontAwesomeIcons.triangleExclamation;
        gradientColors = [const Color(0xFFFFB74D), const Color(0xFFFFA726)];
        break;
      case DialogType.info:
        iconData = FontAwesomeIcons.circleInfo;
        gradientColors = [const Color(0xFF42A5F5), const Color(0xFF1E88E5)];
        break;
      case DialogType.custom:
        return const SizedBox.shrink();
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: FaIcon(
        iconData,
        size: size,
        color: Colors.white,
      ),
    );
  }

  static List<CupertinoDialogAction> _makeActionsButtonsIOS(
      List<CustomActionsButtons>? buttons) {
    if (buttons == null) return [];

    return buttons.map((button) {
      Color? textColor;
      if (button.isPrimary) {
        textColor = const Color(0xFF43A047); // Verde
      } else if (button.isDestructive) {
        textColor = const Color(0xFFE53935); // Rojo
      }

      return CupertinoDialogAction(
        isDestructiveAction: button.isDestructive,
        isDefaultAction: button.isPrimary,
        onPressed: () => button.onTap != null ? button.onTap!() : () {},
        child: Text(
          button.label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: button.isPrimary ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      );
    }).toList();
  }
}

// Header del diálogo
class _DialogHeader extends StatelessWidget {

  const _DialogHeader({required this.title, this.dialogType});
  final String title;
  final DialogType? dialogType;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (dialogType != null && dialogType != DialogType.custom) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getBackgroundColor(dialogType!).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomAlertDialog._getIconWidget(dialogType, size: 16),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(15),
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppThemes.colorCuarto,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(DialogType type) {
    switch (type) {
      case DialogType.error:
        return const Color(0xFFE53935);
      case DialogType.success:
        return const Color(0xFF43A047);
      case DialogType.warning:
        return const Color(0xFFFFA726);
      case DialogType.info:
        return const Color(0xFF1E88E5);
      case DialogType.custom:
        return Colors.grey;
    }
  }
}

// Botones del diálogo
class _DialogActions extends StatelessWidget {

  const _DialogActions({required this.buttons});
  final List<CustomActionsButtons> buttons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index > 0 ? 10 : 0),
              child: _ActionButton(
                label: button.label,
                isPrimary: button.isPrimary,
                isDestructive: button.isDestructive,
                onTap: () => button.onTap != null ? button.onTap!() : () {},
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Botón de acción individual
class _ActionButton extends StatelessWidget {

  const _ActionButton({
    required this.label,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.onTap,
  });
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    List<Color> gradientColors;
    if (isPrimary) {
      gradientColors = [const Color(0xFF66BB6A), const Color(0xFF43A047)];
    } else if (isDestructive) {
      gradientColors = [const Color(0xFFEF5350), const Color(0xFFE53935)];
    } else {
      gradientColors = isDark
          ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
          : [Colors.grey.withValues(alpha: 0.15), Colors.grey.withValues(alpha: 0.1)];
    }

    final textColor = (isPrimary || isDestructive)
        ? Colors.white
        : (isDark ? Colors.white70 : AppThemes.colorCuarto);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: (isPrimary || isDestructive)
                ? [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ResponsiveApp.scaleText(14),
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DialogBody extends StatelessWidget {
  const DialogBody({
    super.key,
    required this.dialogType,
    required this.menssage,
    this.body,
    this.showIcon = false,
  });

  final DialogType? dialogType;
  final String menssage;
  final Widget? body;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Preferences.isDarkMode;

    if (dialogType == DialogType.custom) {
      return body ?? const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          menssage,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: ResponsiveApp.scaleText(14),
            height: 1.5,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 12),
          body!,
        ],
      ],
    );
  }
}
