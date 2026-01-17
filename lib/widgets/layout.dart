import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:provider/provider.dart';

class Layout extends StatelessWidget {
  Layout({
    Key? key,
    required this.bodyContent,
    required this.panelController,
    this.appBarTitle,
    this.appBarLeading,
    this.appBarTrailing,
    this.hasFooter = false,
    this.maxPanelHeightFraction = 0.85,
  }) : super(key: key);

  final Widget bodyContent;
  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;
  final bool? hasFooter;
  final double maxPanelHeightFraction; // Fracción máxima de la pantalla (0.0 a 1.0)

  final PanelController panelController;

  final boxDecoration = const BoxDecoration(
    gradient: LinearGradient(
      transform: GradientRotation(-0.5),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.005, 0.3],
      colors: [Color(0xFF2429AA), Color(0xFF08134F)],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final topPadding = mediaQuery.padding.top;
    
    final fraction = slideUpProvider.maxHeightFraction ?? maxPanelHeightFraction;
    final visibleHeight = screenHeight - keyboardHeight;
    final minTopMargin = topPadding + 80;
    
    // maxHeight: el menor entre (altura deseada, 85% visible, espacio disponible)
    final maxHeight = max(100.0, min(
      screenHeight * fraction,
      min(visibleHeight * maxPanelHeightFraction, visibleHeight - minTopMargin),
    ));

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SlidingUpPanel(
        controller: panelController,
        minHeight: 0,
        maxHeight: maxHeight,
        backdropEnabled: true,
        parallaxEnabled: true,
        backdropOpacity: 0.6,
        backdropTapClosesPanel: slideUpProvider.closeOnOutsideClick,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(blurRadius: 7, spreadRadius: 1, color: Colors.black.withValues(alpha: 0.4))
        ],
        color: AppThemes.themeColor_2,
        onPanelClosed: () {
          cleanSlideUp(slideUpProvider, true);
        },
        panelBuilder: () => _WeSlideContent(panelController: panelController),
        body: Stack(
          children: [
            Container(decoration: boxDecoration),
            _AppBar(title: appBarTitle, leading: appBarLeading, trailing: appBarTrailing),
            _Body(child: bodyContent),
          ],
        ),
      ),
    );
  }

  cleanSlideUp(SlideUpProvider slideUpProvider, [isListener = false]) {
    if (slideUpProvider.body != null) slideUpProvider.body = null;
    FocusManager.instance.primaryFocus?.unfocus();
    slideUpProvider.closeSlideUp(controller: panelController, isListener: isListener);
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({Key? key, this.title, this.leading, this.trailing}) : super(key: key);

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (leading != null) Container(margin: const EdgeInsets.only(right: 5), child: leading!),
            if (title != null)
              Expanded(
                child: Text(title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 2)),
              ),
            if (trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = topPadding + 60;
    
    return Column(
      children: [
        SizedBox(height: appBarHeight),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(70)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(70)),
                color: AppThemes.themeColor_1,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeSlideContent extends StatelessWidget {
  const _WeSlideContent({Key? key, required this.panelController}) : super(key: key);

  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    SlideUpProvider slideUpProvider = context.watch<SlideUpProvider>();
    ThemeProvider themeProvider = context.watch<ThemeProvider>();

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: AppThemes.themeColor_2,
        ),
        child: Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 20),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Positioned(
                    top: -17,
                    child: Icon(
                      Icons.remove_rounded,
                      size: 60,
                      color: Colors.grey.withValues(alpha: 0.5),
                    )),
                Column(
                  children: [
                    Container(height: 25),
                    Expanded(
                      child: KeyedSubtree(
                        key: ValueKey('body_${themeProvider.isDarkMode}'),
                        child: slideUpProvider.body ?? Container(),
                      ),
                    ),
                  ],
                )
              ],
            )));
  }
}
