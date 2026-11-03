import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/theme/colors.dart';
import 'package:altynemel/theme/text_styles.dart';

void main() {
  final original = AltynemelTextStyles.from(AltynemelColors.night);
  final material = AltynemelTextStyles.material(AltynemelColors.night);

  test('the material scale follows the Material 3 sizes', () {
    expect(material.displayXl.fontSize, 32);
    expect(material.displayLg.fontSize, 28);
    expect(material.displayMd.fontSize, 22);
    expect(material.bodyLg.fontSize, 16);
    expect(material.body.fontSize, 14);
    expect(material.bodyStrong.fontSize, 14);
    expect(material.caption.fontSize, 12);
    expect(material.label.fontSize, 12);
  });

  test('line heights match the Material 3 scale', () {
    double lineHeight(TextStyle style) => style.fontSize! * style.height!;
    expect(lineHeight(material.displayXl), closeTo(40, 0.01));
    expect(lineHeight(material.bodyLg), closeTo(24, 0.01));
    expect(lineHeight(material.body), closeTo(20, 0.01));
    expect(lineHeight(material.caption), closeTo(16, 0.01));
  });

  test('the material display text is lighter than the original', () {
    expect(
      material.displayXl.fontSize!,
      lessThan(original.displayXl.fontSize!),
    );
    expect(material.bodyStrong.fontWeight, FontWeight.w500);
    expect(material.body.fontWeight, FontWeight.w400);
  });

  test('times keep tabular figures', () {
    expect(
      material.time.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  test('the text takes its color from the palette', () {
    expect(material.body.color, AltynemelColors.night.ink);
  });
}
