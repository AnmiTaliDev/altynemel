import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/menu.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpMenu(
  WidgetTester tester, {
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Center(
      child: MenuPanel(
        semanticLabel: 'Track menu',
        title: 'Track',
        children: [MenuItem(label: 'Play next', onPressed: () {})],
      ),
    ),
    size: const Size(500, 400),
    style: style,
  );
}

BoxDecoration panel(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(MenuPanel),
          matching: find.byType(Container),
        )
        .first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the Material 3 panel is a rounded elevated surface', (
    tester,
  ) async {
    await pumpMenu(tester);
    final decoration = panel(tester);
    expect(decoration.color, scheme.surfaceContainerHigh);
    expect(decoration.borderRadius, BorderRadius.circular(20));
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNotEmpty);
  });

  testWidgets('the original panel keeps its outline', (tester) async {
    await pumpMenu(tester, style: DesignStyle.altynemel);
    final decoration = panel(tester);
    expect(decoration.border, isNotNull);
    expect(decoration.boxShadow, isNull);
  });

  testWidgets('a pressed item shows the state layer', (tester) async {
    await pumpMenu(tester);
    final touch = await tester.startGesture(
      tester.getCenter(find.text('Play next')),
    );
    await tester.pump();
    final item = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Play next'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (item.decoration! as BoxDecoration).color,
      scheme.onSurface.withValues(alpha: 0.12),
    );
    await touch.up();
  });

  testWidgets('an item still reports taps', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      Center(
        child: MenuPanel(
          semanticLabel: 'Menu',
          children: [MenuItem(label: 'Go', onPressed: () => taps++)],
        ),
      ),
      size: const Size(500, 400),
      style: DesignStyle.material,
    );
    await tester.tap(find.text('Go'));
    expect(taps, 1);
  });
}
