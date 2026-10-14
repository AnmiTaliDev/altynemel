import 'package:flutter/widgets.dart';

import 'playback_controller.dart';

class PlaybackScope extends InheritedNotifier<PlaybackController> {
  const PlaybackScope({
    super.key,
    required PlaybackController playback,
    required super.child,
  }) : super(notifier: playback);

  static PlaybackController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PlaybackScope>()!
        .notifier!;
  }
}
