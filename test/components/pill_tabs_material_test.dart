import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/pill_tabs.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpTabs(
  WidgetTester tester, {
  String selected = 'b',
  ValueChanged<String>? onSelected,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    PillTabs<String>(
      semanticLabel: 'Views',
      selected: selected,
      onSelected: onSelected ?? (_) {},
      options: const [
        PillOption(value: 'a', label: 'Albums'),
        PillOption(value: 'b', label: 'Artists'),
      ],
    ),
    size: const Size(500, 200),
    style: style,
  );
}

BoxDecoration chip(WidgetTester tester, String label) {
  final box = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the selected chip is a filled container with a check', (
    tester,
  ) async {
    await pumpTabs(tester);
    final selected = chip(tester, 'Artists');
    expect(selected.color, scheme.secondaryContainer);
    expect(selected.border, isNull);
    expect(selected.borderRadius, BorderRadius.circular(8));
  });

  testWidgets('an unselected chip is outlined and transparent', (tester) async {
    await pumpTabs(tester);
    final other = chip(tester, 'Albums');
    expect(other.color, Colors.transparent);
    expect((other.border! as Border).top.color, scheme.outline);
  });

  testWidgets('chips are 32 px high', (tester) async {
    await pumpTabs(tester);
    final size = tester.getSize(
      find
          .ancestor(of: find.text('Albums'), matching: find.byType(Container))
          .first,
    );
    expect(size.height, 32);
  });

  testWidgets('tapping a chip selects it', (tester) async {
    String? seen;
    await pumpTabs(tester, onSelected: (v) => seen = v);
    await tester.tap(find.text('Albums'));
    expect(seen, 'a');
  });

  testWidgets('the original style keeps its pills', (tester) async {
    await pumpTabs(tester, style: DesignStyle.altynemel);
    expect(
      chip(tester, 'Artists').borderRadius,
      isNot(BorderRadius.circular(8)),
    );
  });
}
