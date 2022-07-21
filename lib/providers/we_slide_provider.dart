import 'package:flutter/material.dart';

import 'package:we_slide/we_slide.dart';

class WeSlideProvider extends ChangeNotifier {
  WeSlideController? _controller;

  get controller => _controller;

  void initController(WeSlideController controller) {
    _controller ??= controller;
  }

  void closeController() {
    if (_controller == null) return;
    // _controller = null;
  }

  void openWeSlide() {
    if (_controller == null) return;

    _controller!.show();
    notifyListeners();
  }

  Future<void> closeWeSlide() async {
    if (_controller == null) return;

    _controller!.hide();
    await Future.delayed(const Duration(milliseconds: 250));
    notifyListeners();
  }
}
