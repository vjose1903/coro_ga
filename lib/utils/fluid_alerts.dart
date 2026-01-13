import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';

class FluidAlerts {
  FluidAlerts();

  static void show(BuildContext context, {required Widget rootPage, Alignment? firstAlignment = Alignment.center}) {
    showModal(
      context: context,
      builder: (context) => FluidDialog(
        alignmentCurve: Curves.bounceOut,
        // Setting custom durations for all animations.

        sizeDuration: const Duration(milliseconds: 600),
        alignmentDuration: const Duration(milliseconds: 500),
        transitionDuration: const Duration(seconds: 1, milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        // Here we use another animation from the animations package instead of the default one.
        transitionBuilder: (child, animation) => SharedAxisTransition(
          transitionType: SharedAxisTransitionType.scaled,
          animation: animation,
          secondaryAnimation: ReverseAnimation(animation),
          fillColor: Colors.transparent,
          child: child,
        ),
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