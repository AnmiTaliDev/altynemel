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
}
