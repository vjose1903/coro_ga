import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/helpers/helpers.dart';
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
  }) : super(key: key);

  final Widget bodyContent;
  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;
  final bool? hasFooter;

  final SlidingUpPanelController panelController;

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
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

    return Stack(
          children: [
            Container(decoration: boxDecoration),
            _AppBar(title: appBarTitle, leading: appBarLeading, trailing: appBarTrailing),
            _Body(child: bodyContent),
            SlidingUpPanelWidget(
              anchor: 0,
              enableOnTap: false,
              controlHeight: 0,
              panelController: panelController,
              dragDown: (details) {
                // Fun.logColor(color: Colores.cyan, body: "dragDown");
              },
              dragStart: (details) {
                // Fun.logColor(color: Colores.green, body: "dragStart");
                FocusManager.instance.primaryFocus?.unfocus();
              },
              dragCancel: () {
                if (panelController.status == SlidingUpPanelStatus.collapsed || panelController.status == SlidingUpPanelStatus.anchored) {
                  cleanSlideUp(slideUpProvider, true);
                }
              },
              dragUpdate: (details) {
                // Fun.logColor(color: Colores.red, body: "dragUpdate");
              },
              dragEnd: (details) {
                // Fun.logColor(color: Colores.yellow, body: "dragEnd");

                if (panelController.status == SlidingUpPanelStatus.collapsed || panelController.status == SlidingUpPanelStatus.anchored) {
                  cleanSlideUp(slideUpProvider, true);
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: ResponsiveApp.size.height * 0.12),
                decoration: ShapeDecoration(
                  shadows: [
                    if (panelController.status == SlidingUpPanelStatus.expanded)
                      BoxShadow(blurRadius: 0, spreadRadius: (ResponsiveApp.size.height + 200), color: Colors.black.withValues(alpha: 0.6)),
                    if (panelController.status == SlidingUpPanelStatus.expanded)
                      BoxShadow(blurRadius: 7, spreadRadius: 1, color: Colors.black.withValues(alpha: 0.4))
                  ],
                  color: AppThemes.themeColor_2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                ),
                child: _WeSlideContent(panelController: panelController),
              ),
            ),
          ],
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
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    final screenSize = ResponsiveApp.size;
    return Column(
      children: [
        SizedBox(height: screenSize.height * 0.125),
        // SizedBox(height: 110),
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

  final SlidingUpPanelController panelController;

  @override
  Widget build(BuildContext context) {
    SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

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
                  children: [Container(height: 25), Expanded(child: slideUpProvider.body ?? Container())],
                )
              ],
            )));
  }
}
