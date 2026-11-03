import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/icon_data.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

ColorScheme scheme() =>
    materialScheme(AltynemelThemeId.night, AccentChoice.theme);

Future<void> pumpIcon(
  WidgetTester tester, {
  VoidCallback? onPressed,
  bool? pressed,
  bool filled = false,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Center(
      child: AltynemelIconButton(
        icon: IconId.heart,
        label: 'Like',
        onPressed: onPressed,
        pressed: pressed,
        filled: filled,
      ),
    ),
    size: const Size(200, 200),
    style: style,
  );
}

Color fillOf(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(AltynemelIconButton),
          matching: find.byType(Container),
        )
        .first,
  );
  return (box.decoration! as BoxDecoration).color!;
}

Color iconColor(WidgetTester tester) {
  final icon = tester.widget<CustomPaint>(
    find
        .descendant(
          of: find.byType(AltynemelIconButton),
          matching: find.byType(CustomPaint),
        )
        .first,
  );
  return (icon.painter! as dynamic).color as Color;
}

void main() {
  testWidgets('an idle icon button has no fill and a muted icon', (
    tester,
  ) async {
    await pumpIcon(tester, onPressed: () {});
    expect(fillOf(tester), Colors.transparent);
    expect(iconColor(tester), scheme().onSurfaceVariant);
  });

  testWidgets('a toggled on button turns the icon to the primary color', (
    tester,
  ) async {
    await pumpIcon(tester, onPressed: () {}, pressed: true);
    expect(iconColor(tester), scheme().primary);
  });

  testWidgets('a filled icon button has the primary fill', (tester) async {
    await pumpIcon(tester, onPressed: () {}, filled: true);
    expect(fillOf(tester), scheme().primary);
    expect(iconColor(tester), scheme().onPrimary);
  });

  testWidgets('a disabled icon button is dimmed', (tester) async {
    await pumpIcon(tester);
    expect(iconColor(tester), scheme().onSurface.withValues(alpha: 0.38));
  });

  testWidgets('pressing shows a state layer', (tester) async {
    await pumpIcon(tester, onPressed: () {});
    final touch = await tester.startGesture(
      tester.getCenter(find.byType(AltynemelIconButton)),
    );
    await tester.pump();
    expect(
      fillOf(tester),
      Color.alphaBlend(
        scheme().onSurfaceVariant.withValues(alpha: 0.12),
        Colors.transparent,
      ),
    );
    await touch.up();
  });

  testWidgets('the original style keeps its colors', (tester) async {
    await pumpIcon(tester, onPressed: () {}, style: DesignStyle.altynemel);
    expect(fillOf(tester), Colors.transparent);
    expect(iconColor(tester), isNot(scheme().onSurfaceVariant));
  });
}
