import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/steps/appearance_step.dart';
import 'package:altynemel/setup/steps/style_card.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';
import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/style.dart';

import '../support/pump.dart';

Future<AppSettings> pumpStep(
  WidgetTester tester, {
  Size size = const Size(900, 1400),
}) async {
  final settings = AppSettings();
  addTearDown(settings.dispose);
  await pumpThemed(
    tester,
    SingleChildScrollView(child: AppearanceStep(settings: settings)),
    size: size,
  );
  return settings;
}

void main() {
  testWidgets('both styles are offered with the original selected', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(find.text(Strings.setupStyleAltynemel), findsOneWidget);
    expect(find.text(Strings.setupStyleMaterial), findsOneWidget);
    final cards = tester.widgetList<StyleCard>(find.byType(StyleCard)).toList();
    expect(cards.map((c) => c.design), [
      DesignStyle.altynemel,
      DesignStyle.material,
    ]);
    expect(cards.map((c) => c.selected), [true, false]);
  });

  testWidgets('choosing the Material card switches the setting', (
    tester,
  ) async {
    final settings = await pumpStep(tester);
    await tester.tap(find.text(Strings.setupStyleMaterial));
    await tester.pump();
    expect(settings.valueOf(designStyle), DesignStyle.material);
    final cards = tester.widgetList<StyleCard>(find.byType(StyleCard)).toList();
    expect(cards.map((c) => c.selected), [false, true]);
  });

  testWidgets('each preview is drawn in its own style', (tester) async {
    await pumpStep(tester);
    final styles = [
      for (final element in tester.elementList(find.byType(StylePreview)))
        AltynemelStyle.of(
          tester.element(
            find.descendant(
              of: find.byWidget(element.widget),
              matching: find.text(Strings.setupPreviewTrack),
            ),
          ),
        ).material,
    ];
    expect(styles, [false, true]);
  });

  testWidgets('the preview palettes differ between the styles', (tester) async {
    await pumpStep(tester);
    final grounds = [
      for (final element in tester.elementList(find.byType(StylePreview)))
        AltynemelColors.of(
          tester.element(
            find.descendant(
              of: find.byWidget(element.widget),
              matching: find.text(Strings.setupPreviewTrack),
            ),
          ),
        ).ground,
    ];
    expect(grounds[0], isNot(grounds[1]));
  });

  testWidgets('the cards stack on a narrow window', (tester) async {
    await pumpStep(tester, size: const Size(360, 1400));
    final first = tester.getTopLeft(find.byType(StyleCard).first);
    final second = tester.getTopLeft(find.byType(StyleCard).last);
    expect(second.dy, greaterThan(first.dy));
    expect(second.dx, first.dx);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the cards sit side by side on a wide window', (tester) async {
    await pumpStep(tester);
    final first = tester.getTopLeft(find.byType(StyleCard).first);
    final second = tester.getTopLeft(find.byType(StyleCard).last);
    expect(second.dy, first.dy);
    expect(second.dx, greaterThan(first.dx));
  });

  testWidgets('a card is spoken with its title and description', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(
      find.bySemanticsLabel(
        '${Strings.setupStyleMaterial}. ${Strings.setupStyleMaterialHint}',
      ),
      findsOneWidget,
    );
  });
}
