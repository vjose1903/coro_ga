import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../widgets/icon_scale.dart';
import '../widgets/text_scale.dart';

enum ToastType { error, success, warning, info }

class Toast {
  static void show({
    required ToastType type,
    required BuildContext context,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores y configuración según tipo
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case ToastType.info:
        backgroundColor = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFE8F4FD);
        borderColor = const Color(0xFF42A5F5);
        iconColor = const Color(0xFF1E88E5);
        iconData = FontAwesomeIcons.circleInfo;
        break;
      case ToastType.error:
        backgroundColor = isDark ? const Color(0xFF4A1F1F) : const Color(0xFFFDECEC);
        borderColor = const Color(0xFFEF5350);
        iconColor = const Color(0xFFE53935);
        iconData = FontAwesomeIcons.circleXmark;
        break;
      case ToastType.success:
        backgroundColor = isDark ? const Color(0xFF1F3D1F) : const Color(0xFFEDF7ED);
        borderColor = const Color(0xFF66BB6A);
        iconColor = const Color(0xFF43A047);
        iconData = FontAwesomeIcons.circleCheck;
        break;
      case ToastType.warning:
        backgroundColor = isDark ? const Color(0xFF4A3A1F) : const Color(0xFFFFF8E6);
        borderColor = const Color(0xFFFFB74D);
        iconColor = const Color(0xFFFFA726);
        iconData = FontAwesomeIcons.triangleExclamation;
        break;
    }

    toastification.show(
      context: context,
      type: toastType,
      style: ToastificationStyle.minimal,
      alignment: Alignment.bottomCenter,
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: IconScale(iconData, size: 18, color: iconColor),
        ),
      ),
      title: title != null
          ? TextScale(
              title,
              size: 14,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            )
          : null,
      description: message != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextScale(
                  message,
                  size: 13,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (onAction != null && actionLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          toastification.dismissAll();
                          onAction();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [iconColor, iconColor.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: iconColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextScale(
                            actionLabel,
                            size: 12,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : null,
      autoCloseDuration: Duration(seconds: onAction != null ? 6 : 4),
      showProgressBar: false,
      dragToClose: true,
      backgroundColor: backgroundColor,
      borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1.5),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      applyBlurEffect: false,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
