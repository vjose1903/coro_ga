import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FluidAlerts {
  FluidAlerts();

  static void show(BuildContext context, {required Widget rootPage, Alignment? firstAlignment = Alignment.center}) {
    showModal(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: rootPage,
        ),
      ),
    );
  }
}
