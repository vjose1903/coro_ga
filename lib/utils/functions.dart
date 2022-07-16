import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:palestine_console/palestine_console.dart';

enum ToasType { error, success, warning }

class Colores {
  static String red = 'red';
  static String white = 'white';
  static String yellow = 'yellow';
  static String green = 'green';
  static String magenta = 'magenta';
  static String cyan = 'cyan';
  static String blue = 'blue';
}

class Fun {
  static void logColor({required String color, required dynamic body, String title = ''}) {
    final printColors = {
      'red': Print.red,
      'white': Print.white,
      'yellow': Print.yellow,
      'green': Print.green,
      'magenta': Print.magenta,
      'cyan': Print.cyan,
      'blue': Print.blue,
    };

    if (title != '') {
      printColors[color]!(title);
      Print.white('$body');
      print(' ');
    } else {
      printColors[color]!('$body');
      print(' ');
    }
  }

  static bool toBoolean(dynamic arg) {
    if (arg.runtimeType != String || (arg.runtimeType == bool)) return arg;

    return arg == "true" ? true : false;
  }

  static removeKeys(Map<dynamic, dynamic> obj, List<String> keys) {
    for (var key in keys) {
      obj.remove(key);
    }
  }

  static toast({required ToasType type, required context, String? title, String? message}) {
    dynamic nextToast;

    switch (type) {
      case ToasType.error:
        nextToast = MotionToast.error;
        break;
      case ToasType.success:
        nextToast = MotionToast.success;
        break;
      case ToasType.warning:
        nextToast = MotionToast.warning;
        break;
      default:
        nextToast = MotionToast.success;
    }

    nextToast(
      title: title != null ? Text(title, style: const TextStyle(color: Colors.black)) : Container(),
      description: message != null ? Text(message, style: const TextStyle(color: Colors.black)) : Container(),
      dismissable: true,
    ).show(context);
  }
}
