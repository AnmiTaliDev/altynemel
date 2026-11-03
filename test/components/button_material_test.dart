import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/button.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

ColorScheme scheme() =>
    materialScheme(AltynemelThemeId.night, AccentChoice.theme);

Color fillOf(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(AltynemelButton),
          matching: find.byType(Container),
        )
        .first,
  );
  return (box.decoration! as BoxDecoration).color!;
}

Future<void> pumpButton(
  WidgetTester tester,
  ButtonKind kind, {
  VoidCallback? onPressed,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Center(
      child: AltynemelButton(label: 'Play', kind: kind, onPressed: onPressed),
    ),
    size: const Size(400, 200),
    style: style,
  );
}

void main() {
  testWidgets('a filled button is 40 px high with the primary color', (
    tester,
  ) async {
    await pumpButton(tester, ButtonKind.primary, onPressed: () {});
    expect(tester.getSize(find.byType(AltynemelButton)).height, 40);
    expect(fillOf(tester), scheme().primary);
  });

  testWidgets('the original style keeps its 48 px buttons', (tester) async {
    await pumpButton(
      tester,
      ButtonKind.primary,
      onPressed: () {},
      style: DesignStyle.altynemel,
    );
    expect(tester.getSize(find.byType(AltynemelButton)).height, 48);
  });

  testWidgets('a tonal button uses the secondary container', (tester) async {
    await pumpButton(tester, ButtonKind.secondary, onPressed: () {});
    expect(fillOf(tester), scheme().secondaryContainer);
  });

  testWidgets('a text button has no fill and no underline', (tester) async {
    await pumpButton(tester, ButtonKind.text, onPressed: () {});
    expect(fillOf(tester), Colors.transparent);
    final label = tester.widget<Text>(find.text('Play'));
    expect(label.style!.decoration, isNot(TextDecoration.underline));
    expect(label.style!.color, scheme().primary);
  });

  testWidgets('a disabled filled button uses the disabled colors', (
    tester,
  ) async {
    await pumpButton(tester, ButtonKind.primary);
    expect(fillOf(tester), scheme().onSurface.withValues(alpha: 0.12));
    expect(
      tester.widget<Text>(find.text('Play')).style!.color,
      scheme().onSurface.withValues(alpha: 0.38),
    );
  });

  testWidgets('pressing adds the state layer', (tester) async {
    await pumpButton(tester, ButtonKind.primary, onPressed: () {});
    final rest = fillOf(tester);
    final touch = await tester.startGesture(
      tester.getCenter(find.byType(AltynemelButton)),
    );
    await tester.pump();
    final pressed = fillOf(tester);
    await touch.up();
    await tester.pump();
    expect(pressed, isNot(rest));
    expect(
      pressed,
      Color.alphaBlend(
        scheme().onPrimary.withValues(alpha: 0.12),
        scheme().primary,
      ),
    );
    expect(fillOf(tester), rest);
  });
}
