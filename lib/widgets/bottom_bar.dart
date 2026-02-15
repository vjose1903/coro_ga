// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.useLandscapeLayout, this.child, this.panelController});
  final bool useLandscapeLayout;
  final Widget? child;
  final PanelController? panelController;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Preferences.isDarkMode ? const Color(0xEB333333) : const Color(0xFFC4D0E5);
    final SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    final double maxHeight = useLandscapeLayout ? 55.0 : 65.0;

    // Usar la posición del panel para animar la altura suavemente
    // panelPosition va de 0 (cerrado) a 1 (abierto)
    final double animatedHeight = panelController != null ? maxHeight * (1 - slideUpProvider.panelPosition) : maxHeight;
    final double height = animatedHeight > 0 ? animatedHeight + bottomInset : 0;

    return Container(
      height: height,
      width: double.infinity,
      color: backgroundColor,
      child: height > 0
          ? ClipRect(
              child: Padding(
                padding: EdgeInsets.fromLTRB(1, 1, 1, bottomInset + 1),
                child: child ?? Container(),
              ),
            )
          : null,
    );
  }
}
