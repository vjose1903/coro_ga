// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:game_score/providers/providers.dart';
import 'package:provider/provider.dart';

import '../shared_preferences/preferences.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key, this.child, this.panelController}) : super(key: key);
  final Widget? child;
  final PanelController? panelController;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Preferences.isDarkMode ? const Color(0xEB333333) : const Color(0xFFC4D0E5);
    final SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();

    double getHeight(PanelController panelController) {
      return (panelController.isAttached && panelController.isPanelOpen) ? 0 : 65;
    }

    return Container(
      height: panelController != null ? getHeight(panelController!) : 65,
      width: double.infinity,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: child ?? Container(),
      ),
    );
  }
}
