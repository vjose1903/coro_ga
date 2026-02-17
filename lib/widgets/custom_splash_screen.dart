import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../helpers/helpers.dart';
import 'text_scale.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({
    required this.navigateRoute,
    required this.imageSrc,
    required this.backgroundColor,
    super.key,
    this.duration = 2500,
    this.imageSize = 280,
    this.text = '',
    this.textStyle,
  });
  final Widget navigateRoute;
  final int duration;
  final double imageSize;
  final String imageSrc;
  final String text;
  final TextStyle? textStyle;
  final Color backgroundColor;

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
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.navigateRoute,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
                  style: widget.textStyle ??
                      TextStyle(
                          fontSize: ResponsiveApp.scaleText(30),
                          fontFamily: 'Poppins'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedText extends StatefulWidget {
  const _AnimatedText({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<_AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<_AnimatedText> {
  String _displayedText = '';
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
    return TextScale(_displayedText, style: widget.style);
  }
}
