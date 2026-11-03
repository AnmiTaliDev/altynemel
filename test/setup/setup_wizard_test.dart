import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/setup_step.dart';
import 'package:altynemel/setup/setup_wizard.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';

Future<AppSettings> pumpWizard(
  WidgetTester tester, {
  Size size = const Size(1100, 800),
  SetupStep initial = SetupStep.welcome,
  Future<void> Function()? onFinish,
}) async {
  final settings = AppSettings()..setSetupCompleted(false);
  addTearDown(settings.dispose);
  await pumpThemed(
    tester,
    SetupWizard(settings: settings, initialStep: initial, onFinish: onFinish),
    size: size,
  );
  return settings;
}

void main() {
  testWidgets('the wizard starts on the welcome step', (tester) async {
    await pumpWizard(tester);
    expect(find.text(Strings.setupWelcomeTitle), findsOneWidget);
    expect(find.text(Strings.setupBack), findsNothing);
    expect(find.text(Strings.setupSkipAll), findsOneWidget);
    expect(find.text(Strings.setupNext), findsOneWidget);
  });

  testWidgets('next and back move through the steps', (tester) async {
    await pumpWizard(tester);
    await tester.tap(find.text(Strings.setupNext));
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupAppearanceTitle), findsOneWidget);
    expect(find.text(Strings.setupBack), findsOneWidget);
    await tester.tap(find.text(Strings.setupBack));
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupWelcomeTitle), findsOneWidget);
  });

  testWidgets('only optional steps offer skip', (tester) async {
    await pumpWizard(tester, initial: SetupStep.library);
    expect(find.text(Strings.setupSkip), findsOneWidget);
    await tester.tap(find.text(Strings.setupSkip));
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupPlaybackTitle), findsOneWidget);
    await tester.tap(find.text(Strings.setupNext));
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupFinishTitle), findsOneWidget);
    expect(find.text(Strings.setupSkip), findsNothing);
  });

  testWidgets('the last step finishes the setup', (tester) async {
    final settings = await pumpWizard(tester, initial: SetupStep.finish);
    expect(settings.setupCompleted, isFalse);
    expect(find.text(Strings.setupNext), findsNothing);
    await tester.tap(find.text(Strings.setupFinish));
    await tester.pumpAndSettle();
    expect(settings.setupCompleted, isTrue);
  });

  testWidgets('skip setup completes it from the first step', (tester) async {
    final settings = await pumpWizard(tester);
    await tester.tap(find.text(Strings.setupSkipAll));
    await tester.pump();
    expect(settings.setupCompleted, isTrue);
  });

  testWidgets('enter goes forward and escape goes back', (tester) async {
    await pumpWizard(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupAppearanceTitle), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupWelcomeTitle), findsOneWidget);
  });

  testWidgets('escape on the first step stays put', (tester) async {
    await pumpWizard(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupWelcomeTitle), findsOneWidget);
  });

  for (final size in const [Size(1100, 800), Size(360, 700)]) {
    testWidgets('every step lays out at ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpWizard(tester, size: size);
      for (var i = 0; i < SetupStep.values.length; i++) {
        expect(tester.takeException(), isNull);
        if (i < SetupStep.values.length - 1) {
          await tester.tap(find.text(Strings.setupNext));
          await tester.pumpAndSettle();
        }
      }
    });
  }

  testWidgets('finishing waits for the finish action before completing', (
    tester,
  ) async {
    final gate = Completer<void>();
    var started = 0;
    final settings = await pumpWizard(
      tester,
      initial: SetupStep.finish,
      onFinish: () {
        started++;
        return gate.future;
      },
    );
    await tester.tap(find.text(Strings.setupFinish));
    await tester.pump();
    expect(started, 1);
    expect(settings.setupCompleted, isFalse);
    gate.complete();
    await tester.pumpAndSettle();
    expect(settings.setupCompleted, isTrue);
  });
}
