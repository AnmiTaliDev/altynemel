import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/setting_def.dart';
import 'package:altynemel/settings/settings_transfer.dart';

const intDef = IntSetting(
  key: 'fade',
  group: SettingGroup.playback,
  label: 'Fade',
  hint: '',
  defaultValue: 4,
  min: 1,
  max: 12,
);

const boolDef = BoolSetting(
  key: 'hidden',
  group: SettingGroup.library,
  label: 'Hidden',
  hint: '',
  defaultValue: true,
);

const defs = <SettingDef<Object>>[intDef, boolDef];

void main() {
  test('export lists only the changed values', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    final empty = jsonDecode(exportSettings(settings, defs));
    expect(empty['version'], transferVersion);
    expect(empty['values'], isEmpty);
    settings.setValue(intDef, 9);
    final json = jsonDecode(exportSettings(settings, defs));
    expect(json['values'], {'fade': '9'});
  });

  test('import applies known values and reports the count', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    const raw =
        '{"version": 1, "values": {"fade": "9", "hidden": "false", "x": "1"}}';
    expect(importSettings(settings, defs, raw), 2);
    expect(settings.valueOf(intDef), 9);
    expect(settings.valueOf(boolDef), isFalse);
  });

  test('import skips values that do not decode and clamps numbers', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    const raw = '{"version": 1, "values": {"fade": "99", "hidden": "maybe"}}';
    expect(importSettings(settings, defs, raw), 1);
    expect(settings.valueOf(intDef), 12);
    expect(settings.valueOf(boolDef), isTrue);
  });

  test('import rejects text that is not a settings export', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    expect(importSettings(settings, defs, 'not json'), isNull);
    expect(importSettings(settings, defs, '[1]'), isNull);
    expect(
      importSettings(settings, defs, '{"version": 2, "values": {}}'),
      isNull,
    );
    expect(importSettings(settings, defs, '{"version": 1}'), isNull);
  });

  test('an export imports back into fresh settings', () {
    final first = AppSettings();
    final second = AppSettings();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    first.setValue(intDef, 7);
    first.setValue(boolDef, false);
    expect(importSettings(second, defs, exportSettings(first, defs)), 2);
    expect(second.valueOf(intDef), 7);
    expect(second.valueOf(boolDef), isFalse);
  });
}
