import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/functions.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Layout extends StatelessWidget {
  Layout({
    Key? key,
    required this.bodyContent,
    required this.panelController,
    this.appBarTitle,
    this.appBarLeading,
    this.appBarTrailing,
    this.hasFooter = false,
    this.initialSlideUpWidgets,
  }) : super(key: key);

  final Widget bodyContent;
  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;
  final bool? hasFooter;
  final Map<String, Widget?>? initialSlideUpWidgets;

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

    configureSlideUp(slideUpProvider: slideUpProvider, initialSlideUpWidgets: initialSlideUpWidgets);

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        ThemeProvider themeProvider = context.watch<ThemeProvider>();

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
              dragCancel: () async {
                // Fun.logColor(color: Colores.magenta, body: "dragCancel");

                await Future.delayed(const Duration(milliseconds: 100));

                if (panelController.status == SlidingUpPanelStatus.collapsed || panelController.status == SlidingUpPanelStatus.anchored) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  slideUpProvider.closeSlideUp(controller: panelController, isListener: true);
                }
              },
              dragUpdate: (details) {
                // Fun.logColor(color: Colores.red, body: "dragUpdate");
              },
              dragEnd: (details) {
                // Fun.logColor(color: Colores.yellow, body: "dragEnd");

                if (panelController.status == SlidingUpPanelStatus.collapsed || panelController.status == SlidingUpPanelStatus.anchored) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  slideUpProvider.closeSlideUp(controller: panelController, isListener: true);
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.19),
                decoration: ShapeDecoration(
                  shadows: [
                    if (panelController.status == SlidingUpPanelStatus.expanded)
                      BoxShadow(blurRadius: 0, spreadRadius: (MediaQuery.of(context).size.height + 200), color: Colors.black.withOpacity(0.6)),
                    if (panelController.status == SlidingUpPanelStatus.expanded)
                      BoxShadow(blurRadius: 7, spreadRadius: 1, color: Colors.black.withOpacity(0.4))
                  ],
                  color: AppThemes.themeColor_2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                ),
                child: _WeSlideContent(panelController: panelController),
              ),
            ),
            const _Loading(),
          ],
        );
      },
    );
  }

  configureSlideUp({dynamic initialSlideUpWidgets, required SlideUpProvider slideUpProvider}) {
    if (initialSlideUpWidgets != null && initialSlideUpWidgets["footer"] != null) slideUpProvider.footer = initialSlideUpWidgets["footer"];
    if (initialSlideUpWidgets != null && initialSlideUpWidgets["body"] != null) slideUpProvider.body = initialSlideUpWidgets["body"];
  }
}

class _Loading extends StatelessWidget {
  const _Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoadingProvider loadingProvider = context.watch<LoadingProvider>();
    Size size = MediaQuery.of(context).size;
    return Visibility(
      visible: loadingProvider.isLoading,
      child: Positioned(
          top: 0,
          child: Container(
            height: size.height,
            width: size.width,
            color: Colors.black.withOpacity(0.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: LoadingAnimationWidget.staggeredDotsWave(color: AppThemes.colorSegundo, size: 150)),
                const Text('Cargando...', style: TextStyle(fontFamily: "Poppins", fontSize: 25))
              ],
            ),
          )),
    );
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
    final screenSize = MediaQuery.of(context).size;
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
                      color: Colors.grey.withOpacity(0.5),
                    )),
                Column(
                  children: [Container(height: 25), Expanded(child: slideUpProvider.Body ?? Container())],
                )
              ],
            )));
  }
}
