import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum ToastType { error, success, warning, info }

class Toast {
  static void show({
    required ToastType type,
    required BuildContext context,
    String? title,
    String? message,
  }) {
    ToastificationType toastType;

    switch (type) {
      case ToastType.info:
        toastType = ToastificationType.info;
        break;
      case ToastType.error:
        toastType = ToastificationType.error;
        break;
      case ToastType.success:
        toastType = ToastificationType.success;
        break;
      case ToastType.warning:
        toastType = ToastificationType.warning;
        break;
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Colores de fondo según tipo
    Color backgroundColor;
    Color borderColor;
    
    switch (type) {
      case ToastType.info:
        backgroundColor = isDarkMode ? const Color(0xFF2A4A6F) : const Color(0xFFE3F2FD);
        borderColor = isDarkMode ? const Color(0xFF1976D2) : const Color(0xFF1976D2);
        break;
      case ToastType.error:
        backgroundColor = isDarkMode ? const Color(0xFF5C2A2A) : const Color(0xFFFFEBEE);
        borderColor = isDarkMode ? const Color(0xFFD32F2F) : const Color(0xFFD32F2F);
        break;
      case ToastType.success:
        backgroundColor = isDarkMode ? const Color(0xFF2A4D2A) : const Color(0xFFE8F5E9);
        borderColor = isDarkMode ? const Color(0xFF388E3C) : const Color(0xFF388E3C);
        break;
      case ToastType.warning:
        backgroundColor = isDarkMode ? const Color(0xFF5C4A2A) : const Color(0xFFFFF3E0);
        borderColor = isDarkMode ? const Color(0xFFF57C00) : const Color(0xFFF57C00);
        break;
    }

    toastification.show(
      context: context,
      type: toastType,
      style: ToastificationStyle.minimal,
      alignment: Alignment.bottomCenter,
      title: title != null
          ? Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,
      description: message != null ? Text(message) : null,
      autoCloseDuration: const Duration(seconds: 4),
      showProgressBar: false,
      dragToClose: true,
      backgroundColor: backgroundColor,
      borderSide: BorderSide(color: borderColor, width: 1),
    );
  }

  static void success(BuildContext context, {String? title, String? message}) {
    show(type: ToastType.success, context: context, title: title, message: message);
  }

  static void error(BuildContext context, {String? title, String? message}) {
    show(type: ToastType.error, context: context, title: title, message: message);
  }

  static void info(BuildContext context, {String? title, String? message}) {
    show(type: ToastType.info, context: context, title: title, message: message);
  }

  static void warning(BuildContext context, {String? title, String? message}) {
    show(type: ToastType.warning, context: context, title: title, message: message);
  }
}

