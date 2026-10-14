import 'package:flutter/widgets.dart';

import 'window_service.dart';

class WindowScope extends InheritedWidget {
  const WindowScope({super.key, required this.service, required super.child});

  final WindowService service;

  static WindowService? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WindowScope>()?.service;
  }

  @override
  bool updateShouldNotify(WindowScope oldWidget) =>
      service != oldWidget.service;
}
