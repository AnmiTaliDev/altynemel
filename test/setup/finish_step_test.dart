import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/steps/finish_step.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';

Future<AppSettings> pumpStep(
  WidgetTester tester, {
  Size size = const Size(800, 700),
}) async {
  final settings = AppSettings();
  addTearDown(settings.dispose);
  await pumpThemed(
    tester,
    SingleChildScrollView(child: FinishStep(settings: settings)),
    size: size,
  );
  return settings;
}

void main() {
  testWidgets('the summary lists every choice with its default', (
    tester,
  ) async {
    await pumpStep(tester);
    for (final label in [
      Strings.setupSummaryStyle,
      Strings.setupSummaryTheme,
      Strings.setupSummaryAccent,
      Strings.setupSummaryLibrary,
      Strings.setupSummaryPlayback,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Altynemel'), findsOneWidget);
    expect(find.text(Strings.themeSystem), findsOneWidget);
    expect(find.text(Strings.setupSummaryNoFolder), findsOneWidget);
  });

  testWidgets('the summary follows the settings live', (tester) async {
    final settings = await pumpStep(tester);
    settings.setValue(designStyle, DesignStyle.material);
    settings.setTheme(ThemeChoice.day);
    settings.setValue(accentColor, AccentChoice.amber);
    settings.setLibraryFolder('/home/me/Music');
    await tester.pump();
    expect(find.text('Material 3'), findsOneWidget);
    expect(find.text(Strings.themeDay), findsOneWidget);
    expect(find.text('Amber'), findsOneWidget);
    expect(find.text('/home/me/Music'), findsOneWidget);
  });

  test(
    'the playback summary describes gapless, crossfade and normalization',
    () {
      final settings = AppSettings();
      addTearDown(settings.dispose);
      expect(
        playbackSummary(settings),
        'Gapless  ·  No crossfade  ·  Normalization: Off',
      );
      settings.setGapless(false);
      settings.setCrossfade(true);
      settings.setValue(crossfadeSeconds, 8);
      settings.setValue(replayGain, ReplayGainMode.track);
      expect(
        playbackSummary(settings),
        'Gaps between tracks  ·  Crossfade 8 s  ·  Normalization: Track',
      );
    },
  );

  test('every theme choice has a label', () {
    for (final choice in ThemeChoice.values) {
      expect(themeLabel(choice).trim(), isNotEmpty);
    }
  });

  testWidgets('each row is spoken as one phrase', (tester) async {
    await pumpStep(tester);
    expect(
      find.bySemanticsLabel('${Strings.setupSummaryStyle}, Altynemel'),
      findsOneWidget,
    );
  });

  testWidgets('rows stack their label and value on a phone', (tester) async {
    await pumpStep(tester, size: const Size(360, 800));
    final label = tester.getTopLeft(find.text(Strings.setupSummaryStyle));
    final value = tester.getTopLeft(find.text('Altynemel'));
    expect(value.dy, greaterThan(label.dy));
    expect(tester.takeException(), isNull);
  });
}
