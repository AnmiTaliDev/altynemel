import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/style.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/contrast.dart';

void main() {
  test('every accent has a seed', () {
    expect(materialSeeds.keys.toSet(), AccentChoice.values.toSet());
  });

  test('the day theme is light and the others are dark', () {
    expect(
      materialScheme(AltynemelThemeId.day, AccentChoice.theme).brightness,
      Brightness.light,
    );
    for (final id in [AltynemelThemeId.night, AltynemelThemeId.contrast]) {
      expect(
        materialScheme(id, AccentChoice.theme).brightness,
        Brightness.dark,
      );
    }
  });

  test('the accent changes the scheme', () {
    final a = materialScheme(AltynemelThemeId.night, AccentChoice.mint);
    final b = materialScheme(AltynemelThemeId.night, AccentChoice.rose);
    expect(a.primary, isNot(b.primary));
  });

  test('the palette maps the scheme onto the app colors', () {
    final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.sky);
    final colors = materialColors(scheme);
    expect(colors.ground, scheme.surface);
    expect(colors.surface, scheme.surfaceContainer);
    expect(colors.surfaceHigh, scheme.surfaceContainerHigh);
    expect(colors.ink, scheme.onSurface);
    expect(colors.inkMuted, scheme.onSurfaceVariant);
    expect(colors.accent, scheme.primary);
    expect(colors.onAccent, scheme.onPrimary);
    expect(colors.alert, scheme.error);
  });

  for (final id in AltynemelThemeId.values) {
    for (final accent in AccentChoice.values) {
      test(
        'text and accents are readable in ${id.name} with ${accent.name}',
        () {
          final colors = materialColors(materialScheme(id, accent));
          final minimum = id == AltynemelThemeId.contrast ? 7.0 : 4.5;
          for (final ground in [
            colors.ground,
            colors.surface,
            colors.surfaceHigh,
          ]) {
            expect(
              contrastRatio(colors.ink, ground),
              greaterThanOrEqualTo(minimum),
            );
            expect(
              contrastRatio(colors.inkMuted, ground),
              greaterThanOrEqualTo(id == AltynemelThemeId.contrast ? 7.0 : 4.5),
            );
          }
          expect(
            contrastRatio(colors.onAccent, colors.accent),
            greaterThanOrEqualTo(minimum),
          );
          expect(
            contrastRatio(colors.accent, colors.ground),
            greaterThanOrEqualTo(3),
          );
        },
      );
    }
  }

  test('the style extension knows when it is material', () {
    final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);
    expect(AltynemelStyle.original.material, isFalse);
    expect(
      AltynemelStyle(design: DesignStyle.material, scheme: scheme).material,
      isTrue,
    );
    expect(
      const AltynemelStyle(design: DesignStyle.material).material,
      isFalse,
    );
  });
}
