import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/toggle.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpToggle(
  WidgetTester tester, {
  required bool value,
  ValueChanged<bool>? onChanged,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Toggle(title: 'Gapless', value: value, onChanged: onChanged),
    size: const Size(500, 200),
    style: style,
  );
}

Finder track() => find.byWidgetPredicate(
  (w) =>
      w is AnimatedContainer &&
      w.constraints?.maxWidth == 52 &&
      w.constraints?.maxHeight == 32,
);

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the track is 52 by 32 like a Material 3 switch', (tester) async {
    await pumpToggle(tester, value: false, onChanged: (_) {});
    expect(tester.getSize(track()), const Size(52, 32));
  });

  testWidgets('an on switch has the primary track', (tester) async {
    await pumpToggle(tester, value: true, onChanged: (_) {});
    final box = tester.widget<AnimatedContainer>(track());
    expect((box.decoration! as BoxDecoration).color, scheme.primary);
  });

  testWidgets('an off switch is outlined with a small thumb', (tester) async {
    await pumpToggle(tester, value: false, onChanged: (_) {});
    final box = tester.widget<AnimatedContainer>(track());
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, scheme.surfaceContainerHighest);
    expect((decoration.border! as Border).top.color, scheme.outline);
    final thumb = find.descendant(
      of: track(),
      matching: find.byWidgetPredicate(
        (w) => w is AnimatedContainer && w.constraints?.maxWidth == 16,
      ),
    );
    expect(thumb, findsOneWidget);
  });

  testWidgets('the thumb grows when the switch turns on', (tester) async {
    await pumpToggle(tester, value: true, onChanged: (_) {});
    final thumb = find.descendant(
      of: track(),
      matching: find.byWidgetPredicate(
        (w) => w is AnimatedContainer && w.constraints?.maxWidth == 24,
      ),
    );
    expect(thumb, findsOneWidget);
  });

  testWidgets('tapping the row toggles the value', (tester) async {
    bool? seen;
    await pumpToggle(tester, value: false, onChanged: (v) => seen = v);
    await tester.tap(find.text('Gapless'));
    expect(seen, isTrue);
  });

  testWidgets('the original style keeps its 56 px switch', (tester) async {
    await pumpToggle(
      tester,
      value: false,
      onChanged: (_) {},
      style: DesignStyle.altynemel,
    );
    expect(track(), findsNothing);
  });
}
