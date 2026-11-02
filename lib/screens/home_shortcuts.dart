import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class SeekIntent extends Intent {
  const SeekIntent(this.seconds);

  final int seconds;
}

class CollapseIntent extends Intent {
  const CollapseIntent();
}

class MuteIntent extends Intent {
  const MuteIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class GuardedAction<T extends Intent> extends Action<T> {
  GuardedAction({required this.enabled, required this.run});

  final bool Function() enabled;
  final void Function() run;

  @override
  bool isEnabled(T intent) => enabled();

  @override
  Object? invoke(T intent) {
    run();
    return null;
  }
}

const Map<ShortcutActivator, Intent> homeShortcuts = {
  SingleActivator(LogicalKeyboardKey.space): PlayPauseIntent(),
  SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
      PreviousIntent(),
  SingleActivator(LogicalKeyboardKey.arrowRight, control: true): NextIntent(),
  SingleActivator(LogicalKeyboardKey.arrowLeft): SeekIntent(-5),
  SingleActivator(LogicalKeyboardKey.arrowRight): SeekIntent(5),
  SingleActivator(LogicalKeyboardKey.escape): CollapseIntent(),
  SingleActivator(LogicalKeyboardKey.keyM): MuteIntent(),
  SingleActivator(LogicalKeyboardKey.keyF, control: true): FocusSearchIntent(),
};

bool textFieldFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null &&
      context.findAncestorWidgetOfExactType<EditableText>() != null;
}

bool controlFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null &&
      (context.findAncestorWidgetOfExactType<EditableText>() != null ||
          context.findAncestorWidgetOfExactType<FocusableActionDetector>() !=
              null);
}
