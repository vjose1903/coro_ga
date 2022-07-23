import 'package:flutter/material.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:we_slide/we_slide.dart';

class Layout extends StatelessWidget {
  Layout({Key? key, required this.bodyContent, this.appBarTitle, this.appBarLeading, this.appBarTrailing, this.weSlideContent, this.weSlideFooter})
      : super(key: key);

  final Widget bodyContent;
  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;
  final Widget? weSlideContent;
  final Widget? weSlideFooter;

  @override
  Widget build(BuildContext context) {
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    configureWeSlide(weSlideProvider: weSlideProvider, weSlideContent: weSlideContent, weSlideFooter: weSlideFooter);

    Fun.logColor(color: Colores.yellow, body: "BUILD LAYOUT");
    return MainLayout(appBarTitle: appBarTitle, appBarLeading: appBarLeading, appBarTrailing: appBarTrailing, bodyContent: bodyContent);
  }

  configureWeSlide({required WeSlideProvider weSlideProvider, Widget? weSlideContent, Widget? weSlideFooter}) {
    weSlideProvider.configureWeSlide(weSlideFooter: weSlideFooter, weSlidecontent: weSlideContent);
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({Key? key, required this.appBarTitle, required this.appBarLeading, required this.appBarTrailing, required this.bodyContent})
      : super(key: key);

  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;
  final Widget bodyContent;

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
    final WeSlideProvider weSlideProvider = context.watch<WeSlideProvider>();
    Fun.logColor(color: Colores.red, body: "MainLayout");
    return Stack(
      children: [
        WeSlide(
          controller: MyWeSlide.controller,
          panelMinSize: 0,
          panelMaxSize: MediaQuery.of(context).size.height * 0.75,
          isDismissible: false,
          overlay: true,
          overlayOpacity: 0.5,
          footerHeight: MyWeSlide.footer != null ? 75 : 0,
          body: Stack(
            children: [
              Container(decoration: boxDecoration),
              _AppBar(title: appBarTitle, leading: appBarLeading, trailing: appBarTrailing),
              _Body(child: bodyContent),
            ],
          ),
          panel: const _WeSlideContent(),
          footer: const _WeSlideFooter(),
        ),
        const _Loading(),
      ],
    );
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
                Center(child: LoadingAnimationWidget.staggeredDotsWave(color: AppThemes.colorPrimero, size: 150)),
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
    final WeSlideProvider weSlideProvider = context.watch<WeSlideProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leading != null) leading! else Container(),
                if (trailing != null) trailing!,
              ],
            ),
            if (title != null)
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  // "${title!} ${MyWeSlide.footer == null ? "NO FOOT" : "SI FOOT"}",
                  "${title!} ",
                  style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22),
                ),
              )
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
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 150),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(80)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(80)),
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
  const _WeSlideContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: AppThemes.themeColor_2,
        ),
        child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomIconButtom(onTap: () => weSlideProvider.closeWeSlide(), icon: Icons.close, size: IconSize.min, iconSize: 25),
                ),
                const SizedBox(height: 10),
                Expanded(child: MyWeSlide.body ?? Container())
              ],
            )));
  }
}

class _WeSlideFooter extends StatelessWidget {
  const _WeSlideFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppThemes.currentTheme == "dark" ? const Color(0xEB333333) : const Color(0xFFC4D0E5);
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: MyWeSlide.footer ?? Container(),
      ),
    );
  }
}
