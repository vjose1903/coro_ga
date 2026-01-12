import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

enum ToasType { error, success, warning, info }

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
  static void logColor({required String color, required dynamic body, String title = '', bool pretty = false}) {
    if (!kReleaseMode) {
      if (title != '') {
        debugPrint('[$color] $title');
        pretty ? debugPrint(getPrettyJSONString(jsonDecode(body))) : debugPrint(body.toString());
      } else {
        pretty ? debugPrint('[$color] ${getPrettyJSONString(jsonDecode(body))}') : debugPrint('[$color] $body');
      }
    }
  }

  static String getPrettyJSONString(jsonObject) {
    const encoder = JsonEncoder.withIndent("  ");
    return encoder.convert(jsonObject);
  }

  static bool toBoolean(dynamic arg) {
    if (arg.runtimeType != String || arg.runtimeType == bool || arg == null) return arg;

    return arg == "true" ? true : false;
  }

  static removeKeys(Map<dynamic, dynamic> obj, List<String> keys) {
    for (var key in keys) {
      if (obj.containsKey(key)) obj.remove(key);
    }
  }

  static toast({required ToasType type, required context, String? title, String? message}) {
    dynamic nextToast;

    switch (type) {
      case ToasType.info:
        nextToast = MotionToast.info;

        break;
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

  static bool arraySortedOrNot(List<dynamic> arr, dynamic property) {
    int n = arr.length;
    return sortFun(arr, property, n);
  }

  static sortFun(List<dynamic> arr, dynamic property, int n) {
// Array has one or no element or the
    // rest are already checked and approved.
    if (n == 1 || n == 0) return true;

    // Unsorted pair found (Equal values allowed)
    if (arr[n - 1][property] < arr[n - 2][property]) return false;

    // Last pair was sorted
    // Keep on checking
    return sortFun(arr, property, n - 1);
  }
}
