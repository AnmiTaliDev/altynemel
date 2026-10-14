import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/demo/demo_screen.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

void main() {
  for (final id in AltynemelThemeId.values) {
    testWidgets('demo screen builds in ${id.name} without errors', (
      tester,
    ) async {
      await pumpThemed(tester, const DemoScreen(), theme: id);
      expect(tester.takeException(), isNull);
      expect(find.text('Altynemel'), findsOneWidget);
      expect(find.text('fading memories'), findsWidgets);
    });
  }

  testWidgets('demo screen survives 200 percent text scale', (tester) async {
    await pumpThemed(tester, const DemoScreen(), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
