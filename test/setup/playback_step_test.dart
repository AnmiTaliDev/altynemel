import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/steps/playback_step.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';

Future<AppSettings> pumpStep(
  WidgetTester tester, {
  Size size = const Size(700, 1600),
}) async {
  final settings = AppSettings();
  addTearDown(settings.dispose);
  await pumpThemed(
    tester,
    SingleChildScrollView(child: PlaybackStep(settings: settings)),
    size: size,
  );
  return settings;
}

void main() {
  testWidgets('it shows the basic playback choices', (tester) async {
    await pumpStep(tester);
    for (final label in [
      Strings.gapless,
      Strings.crossfade,
      Strings.setupNormalization,
      Strings.volumeStep,
      Strings.setupResume,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('the gapless toggle writes to the settings', (tester) async {
    final settings = await pumpStep(tester);
    expect(settings.gapless, isTrue);
    await tester.tap(find.text(Strings.gapless));
    await tester.pump();
    expect(settings.gapless, isFalse);
  });

  testWidgets('the crossfade length appears only with crossfade on', (
    tester,
  ) async {
    final settings = await pumpStep(tester);
    expect(find.text(crossfadeSeconds.label), findsNothing);
    await tester.tap(find.text(Strings.crossfade));
    await tester.pump();
    expect(settings.crossfade, isTrue);
    expect(find.text(crossfadeSeconds.label), findsOneWidget);
    expect(find.text('4 s'), findsOneWidget);
  });

  testWidgets('normalization is chosen from the three modes', (tester) async {
    final settings = await pumpStep(tester);
    await tester.tap(find.text('Album'));
    await tester.pump();
    expect(settings.valueOf(replayGain), ReplayGainMode.album);
  });

  testWidgets('the volume step offers one, five and ten', (tester) async {
    final settings = await pumpStep(tester);
    await tester.tap(find.text('10'));
    await tester.pump();
    expect(settings.volumeStep, 10);
  });

  testWidgets('resuming on launch can be turned on', (tester) async {
    final settings = await pumpStep(tester);
    expect(settings.valueOf(resumeOnLaunch), isFalse);
    await tester.tap(find.text(Strings.setupResume));
    await tester.pump();
    expect(settings.valueOf(resumeOnLaunch), isTrue);
  });

  testWidgets('it lays out on a phone with large text', (tester) async {
    final settings = AppSettings()..setCrossfade(true);
    addTearDown(settings.dispose);
    await pumpThemed(
      tester,
      SingleChildScrollView(child: PlaybackStep(settings: settings)),
      size: const Size(360, 1800),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
  });
}
