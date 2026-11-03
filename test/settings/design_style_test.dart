import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';

void main() {
  test('the original style is the default', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    expect(settings.valueOf(designStyle), DesignStyle.altynemel);
  });

  test('both styles have a label', () {
    expect(designStyleLabels.keys, DesignStyle.values);
    expect(designStyleLabels[DesignStyle.material], 'Material 3');
  });

  test('the style can be switched and reset', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    settings.setValue(designStyle, DesignStyle.material);
    expect(settings.valueOf(designStyle), DesignStyle.material);
    settings.reset(designStyle);
    expect(settings.valueOf(designStyle), DesignStyle.altynemel);
  });
}
