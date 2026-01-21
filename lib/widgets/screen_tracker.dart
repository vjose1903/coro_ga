import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// Registra la pantalla actual en Firebase Analytics y muestra [child].
class ScreenTracker extends StatefulWidget {
  final String screenName;
  final Widget child;

  const ScreenTracker({
    required this.screenName,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenTracker> createState() => _ScreenTrackerState();
}

class _ScreenTrackerState extends State<ScreenTracker> {
  @override
  void initState() {
    super.initState();
    _reportScreen();
  }

  @override
  void didUpdateWidget(covariant ScreenTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenName != widget.screenName) _reportScreen();
  }

  void _reportScreen() {
    // ignore: unawaited_futures
    FirebaseAnalytics.instance.logScreenView(screenName: widget.screenName);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

