import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/style.dart';
import 'package:altynemel/theme/text_styles.dart';
import 'package:altynemel/theme/themes.dart';

import '../app_settings_apply_test.dart' show homeContext, pumpApp;

void main() {
  test('the original theme carries the original style', () {
    final theme = buildTheme(AltynemelThemeId.night);
    expect(theme.extension<AltynemelStyle>()!.material, isFalse);
    expect(
      theme.extension<AltynemelColors>()!.ground,
      AltynemelColors.night.ground,
    );
  });

  test('the material theme carries a scheme and its own palette', () {
    final theme = buildTheme(
      AltynemelThemeId.night,
      style: DesignStyle.material,
    );
    final style = theme.extension<AltynemelStyle>()!;
    expect(style.material, isTrue);
    expect(theme.colorScheme, style.scheme);
    expect(theme.extension<AltynemelColors>()!.accent, style.scheme!.primary);
    expect(
      theme.extension<AltynemelColors>()!.ground,
      isNot(AltynemelColors.night.ground),
    );
  });

  test('the material theme uses the Material 3 text sizes', () {
    final theme = buildTheme(AltynemelThemeId.day, style: DesignStyle.material);
    expect(theme.extension<AltynemelTextStyles>()!.body.fontSize, 14);
    final original = buildTheme(AltynemelThemeId.day);
    expect(original.extension<AltynemelTextStyles>()!.body.fontSize, 15);
  });

  test('the accent choice drives the material seed', () {
    final mint = buildTheme(
      AltynemelThemeId.night,
      accent: AccentChoice.mint,
      style: DesignStyle.material,
    );
    final rose = buildTheme(
      AltynemelThemeId.night,
      accent: AccentChoice.rose,
      style: DesignStyle.material,
    );
    expect(mint.colorScheme.primary, isNot(rose.colorScheme.primary));
  });

  testWidgets('switching the style restyles the running app', (tester) async {
    final lib = await pumpApp(tester);
    expect(AltynemelStyle.of(homeContext(tester)).material, isFalse);
    final before = AltynemelColors.of(homeContext(tester)).ground;
    lib.settings.setValue(designStyle, DesignStyle.material);
    await tester.pumpAndSettle();
    expect(AltynemelStyle.of(homeContext(tester)).material, isTrue);
    expect(AltynemelColors.of(homeContext(tester)).ground, isNot(before));
    lib.settings.reset(designStyle);
    await tester.pumpAndSettle();
    expect(AltynemelStyle.of(homeContext(tester)).material, isFalse);
  });
}
