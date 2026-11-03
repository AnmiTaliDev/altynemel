import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/setup_step.dart';
import 'package:altynemel/strings.dart';

void main() {
  test('the steps run from welcome to finish', () {
    expect(SetupStep.values, [
      SetupStep.welcome,
      SetupStep.appearance,
      SetupStep.library,
      SetupStep.playback,
      SetupStep.finish,
    ]);
  });

  test('the first and last steps know their place', () {
    expect(SetupStep.welcome.isFirst, isTrue);
    expect(SetupStep.welcome.previous, isNull);
    expect(SetupStep.finish.isLast, isTrue);
    expect(SetupStep.finish.next, isNull);
  });

  test('next and previous walk the order', () {
    expect(SetupStep.welcome.next, SetupStep.appearance);
    expect(SetupStep.library.previous, SetupStep.appearance);
    expect(SetupStep.playback.next, SetupStep.finish);
  });

  test('only the optional steps can be skipped', () {
    expect(SetupStep.library.canSkip, isTrue);
    expect(SetupStep.playback.canSkip, isTrue);
    expect(SetupStep.welcome.canSkip, isFalse);
    expect(SetupStep.appearance.canSkip, isFalse);
    expect(SetupStep.finish.canSkip, isFalse);
  });

  test('every step has a short label', () {
    for (final step in SetupStep.values) {
      expect(step.label.trim(), isNotEmpty);
    }
    expect(SetupStep.library.label, Strings.setupStepLibrary);
  });

  test('the progress text counts from one', () {
    expect(Strings.setupStepOf(2, 5), 'Step 2 of 5');
    expect(Strings.setupLibraryChosen('/music'), 'Selected: /music');
  });
}
