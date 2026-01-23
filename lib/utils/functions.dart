import 'dart:convert';

import 'package:flutter/foundation.dart';

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
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }

  static bool toBoolean(dynamic arg) {
    if (arg.runtimeType != String || arg.runtimeType == bool || arg == null) return arg;

    return arg == 'true' ? true : false;
  }

  static removeKeys(Map<dynamic, dynamic> obj, List<String> keys) {
    for (final key in keys) {
      if (obj.containsKey(key)) obj.remove(key);
    }
  }

  static bool arraySortedOrNot(List<dynamic> arr, dynamic property) {
    final int n = arr.length;
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
