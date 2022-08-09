import 'dart:io';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_score/shared_preferences/preferences.dart';

enum DialogType { error, success, warning, info, custom }

class CustomActionsButtons {
  CustomActionsButtons({this.textColor, required this.label, this.onTap});

  final String label;
  final Function? onTap;
  final Color? textColor;

  static Color? defaultTextColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.7) : Colors.blueGrey[600]!.withOpacity(0.7);

  factory CustomActionsButtons.cancelButton(Map<String, dynamic> json) => CustomActionsButtons(
        label: json["label"] ?? "Cancelar",
        onTap: json["onTap"] ?? () {},
        textColor: json["textColor"] ?? Colors.red[800],
      );

  factory CustomActionsButtons.aceptarButton(Map<String, dynamic> json) => CustomActionsButtons(
        label: json["label"] ?? "Aceptar",
        onTap: json["onTap"] ?? () {},
        textColor: json["textColor"] ?? defaultTextColor,
      );
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
      displayDialogAndroid(context: context, menssage: menssage, title: title, dialogType: dialogType, body: body, buttonsList: buttonsList);
    } else {
      displayDialogIOs(context: context, menssage: menssage, title: title, dialogType: dialogType, body: body, buttonsList: buttonsList);
    }
  }

  static void displayDialogAndroid(
      {required BuildContext context,
      required String title,
      required String menssage,
      Widget? body,
      List<CustomActionsButtons>? buttonsList,
      DialogType? dialogType}) {
    showDialog(
        barrierDismissible: buttonsList == null || buttonsList.isEmpty, // Esto se usa para que se pueda quitar la alerta dando click en el overlay
        context: context,
        builder: (buildContext) {
          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              title: Text(title),
              actions: _makeActionsButtons(buttonsList),
              content: DialogBody(
                dialogType: dialogType,
                menssage: menssage,
                body: body,
              ));
        });
  }

  static void displayDialogIOs(
      {required BuildContext context,
      required String title,
      required String menssage,
      Widget? body,
      List<CustomActionsButtons>? buttonsList,
      DialogType? dialogType}) {
    showCupertinoDialog(
        barrierDismissible: buttonsList == null || buttonsList.isEmpty,
        context: context,
        builder: (buildContext) {
          return CupertinoAlertDialog(
              title: Text(title),
              actions: _makeActionsButtons(buttonsList),
              content: DialogBody(
                dialogType: dialogType,
                menssage: menssage,
                body: body,
              ));
        });
  }

  static Icon? _getIcon(DialogType? type) {
    Icon? myIcon;

    if (type == DialogType.error) myIcon = Icon(Icons.cancel_outlined, color: Colors.red[800]!.withOpacity(0.5), size: 50);
    if (type == DialogType.info) myIcon = const Icon(Icons.info_outline);
    if (type == DialogType.success) myIcon = const Icon(Icons.check_circle_outline);
    if (type == DialogType.warning) myIcon = const Icon(Icons.warning_amber_rounded);

    return myIcon;
  }

  static List<TextButton> _makeActionsButtons(List<CustomActionsButtons>? buttons) {
    List<TextButton> buttonsList = [];
    if (buttons != null) {
      for (var button in buttons) {
        dynamic uno = TextButton(
          onPressed: () => button.onTap != null ? button.onTap!() : () {},
          child: Text(button.label, textAlign: TextAlign.justify, style: TextStyle(color: button.textColor ?? CustomActionsButtons.defaultTextColor)),
        );
        buttonsList.add(uno);
      }
    }

    return buttonsList;
  }
}

class DialogBody extends StatelessWidget {
  const DialogBody({Key? key, required this.dialogType, required this.menssage, this.body}) : super(key: key);

  final DialogType? dialogType;
  final String menssage;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: dialogType == DialogType.custom,
      builder: (context) {
        return body != null ? body! : Container();
      },
      fallback: (context) {
        return Row(mainAxisSize: MainAxisSize.min, children: [
          if (dialogType != null) CustomAlertDialog._getIcon(dialogType)!,
          const SizedBox(width: 10),
          Flexible(child: Text(menssage)),
        ]);
      },
    );
  }
}
