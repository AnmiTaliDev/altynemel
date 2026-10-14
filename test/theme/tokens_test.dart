import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/radii.dart';
import 'package:altynemel/theme/spacing.dart';
import 'package:altynemel/theme/text_styles.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/design_tokens.dart';

Color hex(String value) =>
    Color(0xFF000000 | int.parse(value.substring(1), radix: 16));

Map<String, Color> colorMap(AltynemelColors c) => {
  'ground': c.ground,
  'surface': c.surface,
  'surface-high': c.surfaceHigh,
  'line': c.line,
  'line-strong': c.lineStrong,
  'ink': c.ink,
  'ink-muted': c.inkMuted,
  'ink-disabled': c.inkDisabled,
  'accent': c.accent,
  'on-accent': c.onAccent,
  'ok': c.ok,
  'alert': c.alert,
};

void main() {
  final skip = designTokensAvailable
      ? null
      : 'design tokens not found at $designTokensPath';

  group('colors', () {
    for (final id in AltynemelThemeId.values) {
      test('${id.name} matches tokens.json', () {
        final expected = colorTokens(loadDesignTokens(), id.name);
        final actual = colorMap(colorsFor(id));
        expect(actual.keys.toSet(), expected.keys.toSet());
        for (final name in expected.keys) {
          expect(
            actual[name],
            hex(expected[name]!),
            reason: '$name in ${id.name}',
          );
        }
      }, skip: skip);
    }
  });

  group('spacing', () {
    test('matches tokens.json', () {
      final t = pixelTokens(loadDesignTokens(), 'spacing');
      expect(t['space-1'], space1);
      expect(t['space-2'], space2);
      expect(t['space-3'], space3);
      expect(t['space-4'], space4);
      expect(t['space-5'], space5);
      expect(t['space-6'], space6);
      expect(t['space-7'], space7);
      expect(t['space-8'], space8);
      expect(t['target-min'], targetMin);
      expect(t['target-pointer'], targetPointer);
      expect(t['target-lg'], targetLg);
      expect(t['sidebar-w'], sidebarWidth);
      expect(t['playerbar-h'], playerBarHeight);
      expect(t.length, 13);
    }, skip: skip);
  });

  group('radii', () {
    test('matches tokens.json', () {
      final t = pixelTokens(loadDesignTokens(), 'radius');
      expect(t['radius-art'], radiusArt);
      expect(t['radius-control'], radiusControl);
      expect(t['radius-card'], radiusCard);
      expect(t['radius-pill'], radiusPill);
      expect(t.length, 4);
    }, skip: skip);
  });

  group('text styles', () {
    test('match tokens.json', () {
      final tokens = typeTokens(loadDesignTokens());
      final s = AltynemelTextStyles.from(AltynemelColors.night);
      final actual = {
        'display-xl': s.displayXl,
        'display-lg': s.displayLg,
        'display-md': s.displayMd,
        'body-lg': s.bodyLg,
        'body': s.body,
        'body-strong': s.bodyStrong,
        'caption': s.caption,
        'label': s.label,
        'time': s.time,
      };
      expect(actual.keys.toSet(), tokens.keys.toSet());
      for (final entry in tokens.entries) {
        final style = actual[entry.key]!;
        final spec = entry.value;
        final size = double.parse(
          (spec['fontSize'] as String).replaceAll('px', ''),
        );
        final line = double.parse(
          (spec['lineHeight'] as String).replaceAll('px', ''),
        );
        final spacing = spec['letterSpacing'] == null
            ? 0.0
            : double.parse(
                (spec['letterSpacing'] as String).replaceAll('em', ''),
              );
        expect(style.fontFamily, 'Onest', reason: entry.key);
        expect(style.fontSize, size, reason: entry.key);
        expect(
          style.height! * style.fontSize!,
          closeTo(line, 0.001),
          reason: entry.key,
        );
        expect(style.fontWeight!.value, spec['fontWeight'], reason: entry.key);
        expect(
          style.letterSpacing,
          closeTo(spacing * size, 0.001),
          reason: entry.key,
        );
      }
    }, skip: skip);

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
