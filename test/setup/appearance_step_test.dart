import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/steps/accent_swatches.dart';
import 'package:altynemel/setup/steps/appearance_step.dart';
import 'package:altynemel/setup/steps/style_card.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';
import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/accents.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/style.dart';
import 'package:altynemel/theme/themes.dart';

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

  testWidgets('the theme row changes the theme', (tester) async {
    final settings = await pumpStep(tester);
    await tester.tap(find.text(Strings.themeDay));
    await tester.pump();
    expect(settings.theme, ThemeChoice.day);
    await tester.tap(find.text(Strings.themeContrast));
    await tester.pump();
    expect(settings.theme, ThemeChoice.contrast);
  });

  testWidgets('every accent has a swatch and tapping one selects it', (
    tester,
  ) async {
    final settings = await pumpStep(tester);
    for (final choice in AccentChoice.values) {
      expect(find.text(accentLabels[choice]!), findsOneWidget);
    }
    await tester.tap(find.text(accentLabels[AccentChoice.rose]!));
    await tester.pump();
    expect(settings.valueOf(accentColor), AccentChoice.rose);
  });

  testWidgets('a theme choice recolors the previews', (tester) async {
    final settings = await pumpStep(tester);
    Color preview() => AltynemelColors.of(
      tester.element(
        find.descendant(
          of: find.byType(StylePreview).first,
          matching: find.text(Strings.setupPreviewTrack),
        ),
      ),
    ).ground;
    settings.setTheme(ThemeChoice.night);
    await tester.pump();
    final night = preview();
    settings.setTheme(ThemeChoice.day);
    await tester.pump();
    expect(preview(), isNot(night));
  });

  test('swatch colors follow the design style', () {
    final original = swatchColors(
      AccentChoice.rose,
      AltynemelThemeId.night,
      DesignStyle.altynemel,
    );
    final material = swatchColors(
      AccentChoice.rose,
      AltynemelThemeId.night,
      DesignStyle.material,
    );
    expect(
      original.accent,
      accentPair(AccentChoice.rose, AltynemelThemeId.night)!.$1,
    );
    expect(
      material.accent,
      materialScheme(AltynemelThemeId.night, AccentChoice.rose).primary,
    );
    expect(original.accent, isNot(material.accent));
  });

  test('the theme default swatch shows the style default', () {
    final original = swatchColors(
      AccentChoice.theme,
      AltynemelThemeId.day,
      DesignStyle.altynemel,
    );
    expect(original.accent, colorsFor(AltynemelThemeId.day).accent);
  });

  testWidgets('the selected swatch shows a check', (tester) async {
    final settings = await pumpStep(tester);
    settings.setValue(accentColor, AccentChoice.sky);
    await tester.pump();
    expect(
      find.bySemanticsLabel(accentLabels[AccentChoice.sky]!),
      findsOneWidget,
    );
    expect(
      tester
          .widgetList<AccentSwatches>(find.byType(AccentSwatches))
          .single
          .selected,
      AccentChoice.sky,
    );
  });
}
