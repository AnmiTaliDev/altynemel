import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/accents.dart';
import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/contrast.dart';

void main() {
  test('the theme default has no override', () {
    for (final id in AltynemelThemeId.values) {
      expect(accentPair(AccentChoice.theme, id), isNull);
    }
  });

  for (final id in AltynemelThemeId.values) {
    final colors = colorsFor(id);
    for (final choice in AccentChoice.values.skip(1)) {
      test('${choice.name} accent is readable on ${id.name}', () {
        final (accent, onAccent) = accentPair(choice, id)!;
        expect(contrastRatio(accent, onAccent), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(accent, colors.ground), greaterThanOrEqualTo(3));
        expect(contrastRatio(accent, colors.surface), greaterThanOrEqualTo(3));
      });
    }
  }

  test('building a theme applies the chosen accent', () {
    final theme = buildTheme(AltynemelThemeId.night, accent: AccentChoice.rose);
    final colors = theme.extension<AltynemelColors>()!;
    expect(
      colors.accent,
      accentPair(AccentChoice.rose, AltynemelThemeId.night)!.$1,
    );
  });
}
