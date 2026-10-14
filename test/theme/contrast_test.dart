import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/theme/themes.dart';

import '../support/contrast.dart';

void main() {
  for (final id in AltynemelThemeId.values) {
    final c = colorsFor(id);
    final grounds = {
      'ground': c.ground,
      'surface': c.surface,
      'surface-high': c.surfaceHigh,
    };
    final textMin = id == AltynemelThemeId.contrast ? 7.0 : 4.5;

    group(id.name, () {
      final text = {
        'ink': c.ink,
        'ink-muted': c.inkMuted,
        'ok': c.ok,
        'alert': c.alert,
      };
      for (final fg in text.entries) {
        for (final bg in grounds.entries) {
          test('${fg.key} on ${bg.key} is at least $textMin:1', () {
            expect(
              contrastRatio(fg.value, bg.value),
              greaterThanOrEqualTo(textMin),
            );
          });
        }
      }

      final shapes = {'line-strong': c.lineStrong, 'accent': c.accent};
      for (final fg in shapes.entries) {
        for (final bg in grounds.entries) {
          test('${fg.key} on ${bg.key} is at least 3:1', () {
            expect(
              contrastRatio(fg.value, bg.value),
              greaterThanOrEqualTo(3.0),
            );
          });
        }
      }

      test('on-accent on accent is at least $textMin:1', () {
        expect(
          contrastRatio(c.onAccent, c.accent),
          greaterThanOrEqualTo(textMin),
        );
      });
    });
  }
}
