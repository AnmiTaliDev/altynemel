import 'package:flutter/widgets.dart';

import 'library_controller.dart';

class LibraryScope extends InheritedNotifier<LibraryController> {
  const LibraryScope({
    super.key,
    required LibraryController library,
    required super.child,
  }) : super(notifier: library);

  static LibraryController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LibraryScope>()!
        .notifier!;
  }
}
