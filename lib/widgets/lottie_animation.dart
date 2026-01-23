import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatefulWidget {
  const LottieAnimation({super.key, required this.animationJson});
  final String animationJson;

  @override
  State<LottieAnimation> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LottieAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Lottie.asset(
      widget.animationJson,
      controller: _controller,
      onLoaded: (composition) {
        // Configure the AnimationController with the duration of the
        // Lottie file and start the animation.
        // print(composition.duration);

        // _controller.repeat(
        //   min: 0.1,
        //   max: 0.9,
        //   reverse: true,
        //   period: composition.duration,
        // );

        _controller
          ..duration = composition.duration
          ..forward();
      },
    ));
  }
}
