import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/phone_nav.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpNav(
  WidgetTester tester, {
  PhoneTab selected = PhoneTab.queue,
  ValueChanged<PhoneTab>? onSelected,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Align(
      alignment: Alignment.bottomCenter,
      child: PhoneNav(selected: selected, onSelected: onSelected ?? (_) {}),
    ),
    size: const Size(400, 700),
    style: style,
  );
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the bar is 80 px high like a Material 3 navigation bar', (
    tester,
  ) async {
    await pumpNav(tester);
    expect(tester.getSize(find.byType(PhoneNav)).height, 80);
  });

  testWidgets('the current tab has a 64 by 32 indicator', (tester) async {
    await pumpNav(tester);
    final indicator = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == scheme.secondaryContainer,
    );
    expect(indicator, findsOneWidget);
    expect(tester.getSize(indicator), const Size(64, 32));
  });

  testWidgets('the current label is brighter than the others', (tester) async {
    await pumpNav(tester);
    expect(
      tester.widget<Text>(find.text('Queue')).style!.color,
      scheme.onSurface,
    );
    expect(
      tester.widget<Text>(find.text('Library')).style!.color,
      scheme.onSurfaceVariant,
    );
  });

  testWidgets('tapping a tab reports it', (tester) async {
    PhoneTab? seen;
    await pumpNav(tester, onSelected: (tab) => seen = tab);
    await tester.tap(find.text('Settings'));
    expect(seen, PhoneTab.settings);
  });

  testWidgets('the original style keeps its compact bar', (tester) async {
    await pumpNav(tester, style: DesignStyle.altynemel);
    expect(tester.getSize(find.byType(PhoneNav)).height, lessThan(80));
  });
}
