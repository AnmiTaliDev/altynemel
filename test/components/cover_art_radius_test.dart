import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/cover_art.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/app_settings_scope.dart';
import 'package:altynemel/settings/catalog.dart';

import '../support/pump.dart';

double cornerOf(WidgetTester tester) {
  final clip = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
  return (clip.borderRadius as BorderRadius).topLeft.x;
}

void main() {
  testWidgets('a square cover uses the default corner radius', (tester) async {
    await pumpThemed(tester, const CoverArt(size: 80));
    expect(cornerOf(tester), 12);
  });

  testWidgets('the corner radius follows the setting', (tester) async {
    final settings = AppSettings()..setValue(coverRadius, 4);
    addTearDown(settings.dispose);
    await pumpThemed(
      tester,
      AppSettingsScope(settings: settings, child: const CoverArt(size: 80)),
    );
    expect(cornerOf(tester), 4);
    settings.setValue(coverRadius, 30);
    await tester.pump();
    expect(cornerOf(tester), 30);
  });

  testWidgets('an explicit radius wins over the setting', (tester) async {
    final settings = AppSettings()..setValue(coverRadius, 4);
    addTearDown(settings.dispose);
    await pumpThemed(
      tester,
      AppSettingsScope(
        settings: settings,
        child: const CoverArt(size: 80, radius: 20),
      ),
    );
    expect(cornerOf(tester), 20);
  });
}
