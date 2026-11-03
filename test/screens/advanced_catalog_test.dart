import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/setting_rows.dart';
import 'package:altynemel/screens/advanced_settings_screen.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';

import '../support/fonts.dart';
import '../support/pump.dart';

void main() {
  setUpAll(loadOnest);

  for (final size in const [Size(1000, 30000), Size(360, 40000)]) {
    for (final scale in const [1.0, 1.5]) {
      testWidgets(
        'the whole catalog renders at ${size.width.toInt()} px, scale $scale',
        (tester) async {
          final settings = AppSettings();
          addTearDown(settings.dispose);
          await pumpThemed(
            tester,
            AdvancedSettingsScreen(settings: settings, onBack: () {}),
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(ResettableRow), findsNWidgets(allSettings.length));
        },
      );
    }
  }

  testWidgets('searching the real catalog finds the crossfade settings', (
    tester,
  ) async {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    await pumpThemed(
      tester,
      AdvancedSettingsScreen(settings: settings, onBack: () {}),
      size: const Size(1000, 4000),
    );
    await tester.enterText(find.byType(TextField).first, 'crossfade');
    await tester.pump();
    expect(find.text('Crossfade length'), findsOneWidget);
    expect(find.text('Crossfade curve'), findsOneWidget);
    expect(find.text('Crossfade update step'), findsOneWidget);
    expect(find.text('Seek step'), findsNothing);
  });
}
