import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/material.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';

class Layout extends StatelessWidget {
  Layout({Key? key, required this.bodyContent, this.appBarTitle, this.appBarLeading, this.appBarTrailing}) : super(key: key);

  final Widget bodyContent;
  final String? appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarTrailing;

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
    return Stack(
      children: [
        Container(decoration: boxDecoration),
        _AppBar(title: appBarTitle, leading: appBarLeading, trailing: appBarTrailing),
        _Body(child: bodyContent)
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 55),
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
          const SizedBox(height: 5),
          if (title != null)
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                title!,
                style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 25),
              ),
            )
        ],
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
        const SizedBox(height: 180),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(80)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(80)),
                color: AppThemes.fondos[AppThemes.currentTheme],
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
