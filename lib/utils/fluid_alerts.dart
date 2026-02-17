import 'package:animations/animations.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class FluidAlerts {
  FluidAlerts();

  static void show(BuildContext context,
      {required Widget rootPage,
      Alignment? firstAlignment = Alignment.center}) {
    showModal(
      context: context,
      builder: (context) => FluidDialog(
        alignmentCurve: Curves.easeOutCubic,
        // Setting custom durations for all animations.

        sizeDuration: const Duration(milliseconds: 400),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        // Here we use another animation from the animations package instead of the default one.
        transitionBuilder: (child, animation) {
          final landingAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final retreatAnimation = CurvedAnimation(
            parent: ReverseAnimation(animation),
            curve: Curves.easeIn,
          );
          return SharedAxisTransition(
            transitionType: SharedAxisTransitionType.scaled,
            animation: landingAnimation,
            secondaryAnimation: retreatAnimation,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        // Configuring how the dialog looks.
        defaultDecoration: BoxDecoration(
          color: AppThemes.themeColor_2,
          borderRadius: BorderRadius.circular(10),
        ),
        // Setting the first dialog page.
        rootPage: FluidDialogPage(
          alignment: firstAlignment!,
          builder: (context) => rootPage,
        ),
      ),
    );
  }
}
