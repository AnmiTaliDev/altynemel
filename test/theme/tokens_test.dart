import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/text_styles.dart';
import 'package:altynemel/theme/themes.dart';

void main() {
  group('text styles', () {
    test('time uses tabular figures', () {
      final s = AltynemelTextStyles.from(AltynemelColors.night);
      expect(s.time.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    test('no style is smaller than 13 px', () {
      final s = AltynemelTextStyles.from(AltynemelColors.night);
      for (final style in [
        s.displayXl,
        s.displayLg,
        s.displayMd,
        s.bodyLg,
        s.body,
        s.bodyStrong,
        s.caption,
        s.label,
        s.time,
      ]) {
        expect(style.fontSize, greaterThanOrEqualTo(13));
      }
    });
  });

  group('theme', () {
    for (final id in AltynemelThemeId.values) {
      test('${id.name} exposes both extensions', () {
        final theme = buildTheme(id);
        expect(theme.extension<AltynemelColors>(), colorsFor(id));
        expect(theme.extension<AltynemelTextStyles>(), isNotNull);
        expect(theme.scaffoldBackgroundColor, colorsFor(id).ground);
      });
    }
  });
}
