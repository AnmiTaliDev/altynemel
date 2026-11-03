import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/progress_bar.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpBar(
  WidgetTester tester, {
  ValueChanged<double>? onChanged,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    SizedBox(
      width: 300,
      child: ProgressBar(
        value: 50,
        max: 100,
        semanticLabel: 'Seek',
        semanticValueOf: (v) => '$v',
        onChanged: onChanged,
      ),
    ),
    size: const Size(400, 200),
    style: style,
  );
}

List<DecoratedBox> parts(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(ProgressBar),
        matching: find.byType(DecoratedBox),
      ),
    )
    .where((box) => box.decoration is BoxDecoration)
    .toList();

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the active track is primary and the rest is a container', (
    tester,
  ) async {
    await pumpBar(tester, onChanged: (_) {});
    final colors = [
      for (final box in parts(tester)) (box.decoration as BoxDecoration).color,
    ];
    expect(colors, contains(scheme.secondaryContainer));
    expect(
      colors.where((c) => c == scheme.primary).length,
      greaterThanOrEqualTo(2),
    );
  });

  testWidgets('the handle is a 20 px circle without a ring', (tester) async {
    await pumpBar(tester, onChanged: (_) {});
    final handle = parts(tester).firstWhere(
      (box) => (box.decoration as BoxDecoration).shape == BoxShape.circle,
    );
    expect((handle.decoration as BoxDecoration).border, isNull);
    final size = tester.getSize(find.byWidget(handle));
    expect(size, const Size(20, 20));
  });

  testWidgets('the original style keeps its 22 px handle with a ring', (
    tester,
  ) async {
    await pumpBar(tester, onChanged: (_) {}, style: DesignStyle.altynemel);
    final handle = parts(tester).firstWhere(
      (box) => (box.decoration as BoxDecoration).shape == BoxShape.circle,
    );
    expect((handle.decoration as BoxDecoration).border, isNotNull);
    expect(tester.getSize(find.byWidget(handle)), const Size(22, 22));
  });

  testWidgets('a disabled bar is dimmed', (tester) async {
    await pumpBar(tester);
    final colors = [
      for (final box in parts(tester)) (box.decoration as BoxDecoration).color,
    ];
    expect(colors, contains(scheme.onSurface.withValues(alpha: 0.38)));
    expect(colors, isNot(contains(scheme.primary)));
  });

  testWidgets('tapping still seeks', (tester) async {
    double? seen;
    await pumpBar(tester, onChanged: (v) => seen = v);
    final rect = tester.getRect(find.byType(ProgressBar));
    await tester.tapAt(Offset(rect.left + rect.width * 0.8, rect.center.dy));
    expect(seen, closeTo(80, 1));
  });
}
