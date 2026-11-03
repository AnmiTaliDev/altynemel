import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/search_field.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpField(
  WidgetTester tester, {
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    const Center(child: SizedBox(width: 400, child: SearchField())),
    size: const Size(500, 200),
    style: style,
  );
}

BoxDecoration decoration(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(SearchField),
          matching: find.byType(Container),
        )
        .first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the bar is 56 px high and filled', (tester) async {
    await pumpField(tester);
    expect(tester.getSize(find.byType(SearchField)).height, 56);
    expect(decoration(tester).color, scheme.surfaceContainerHigh);
  });

  testWidgets('focus draws a primary outline', (tester) async {
    await pumpField(tester);
    expect(
      (decoration(tester).border! as Border).top.color,
      Colors.transparent,
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final border = decoration(tester).border! as Border;
    expect(border.top.color, scheme.primary);
    expect(border.top.width, 2);
  });

  testWidgets('the original style keeps its 40 px bordered field', (
    tester,
  ) async {
    await pumpField(tester, style: DesignStyle.altynemel);
    expect(tester.getSize(find.byType(SearchField)).height, 40);
    expect(decoration(tester).color, isNot(scheme.surfaceContainerHigh));
  });

  testWidgets('typing still reports changes', (tester) async {
    String? seen;
    await pumpThemed(
      tester,
      Center(
        child: SizedBox(
          width: 400,
          child: SearchField(onChanged: (v) => seen = v),
        ),
      ),
      size: const Size(500, 200),
      style: DesignStyle.material,
    );
    await tester.enterText(find.byType(TextField), 'ørk');
    expect(seen, 'ørk');
  });
}
