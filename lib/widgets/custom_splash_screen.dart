import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class CustomSplashScreen extends StatefulWidget {
  final Widget navigateRoute;
  final int duration;
  final double imageSize;
  final String imageSrc;
  final String text;
  final TextStyle? textStyle;
  final Color backgroundColor;

  const CustomSplashScreen({
    Key? key,
    required this.navigateRoute,
    this.duration = 2500,
    this.imageSize = 280,
    required this.imageSrc,
    this.text = "",
    this.textStyle,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(Duration(milliseconds: widget.duration), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget.navigateRoute,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Image.asset(
                widget.imageSrc,
                width: widget.imageSize,
                height: widget.imageSize,
              ),
            ),
            const SizedBox(height: 30),
            if (widget.text.isNotEmpty)
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: _AnimatedText(
                  text: widget.text,
                  style: widget.textStyle ?? const TextStyle(fontSize: 30.0, fontFamily: "Poppins"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _AnimatedText({required this.text, required this.style});

  @override
  State<_AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<_AnimatedText> {
  String _displayedText = "";
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _animateText();
  }

  void _animateText() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _charIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_charIndex];
          _charIndex++;
        });
        _animateText();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayedText, style: widget.style);
  }
}

