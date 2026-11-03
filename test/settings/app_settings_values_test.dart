import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/setting_def.dart';

const intDef = IntSetting(
  key: 'i',
  group: SettingGroup.playback,
  label: 'Int',
  hint: '',
  defaultValue: 5,
  min: 1,
  max: 10,
);

const boolDef = BoolSetting(
  key: 'b',
  group: SettingGroup.layout,
  label: 'Bool',
  hint: '',
  defaultValue: true,
);

void main() {
  late AppSettings settings;
  var notified = 0;

  setUp(() {
    settings = AppSettings()..addListener(() => notified++);
    notified = 0;
  });

  tearDown(() => settings.dispose());

  test('values start at the default and are not modified', () {
    expect(settings.valueOf(intDef), 5);
    expect(settings.isModified(intDef), isFalse);
  });

  test('a changed value is stored, normalized and notified', () {
    settings.setValue(intDef, 99);
    expect(settings.valueOf(intDef), 10);
    expect(settings.isModified(intDef), isTrue);
    expect(notified, 1);
  });

  test('setting the same value does not notify', () {
    settings.setValue(intDef, 5);
    expect(notified, 0);
    settings.setValue(intDef, 7);
    settings.setValue(intDef, 7);
    expect(notified, 1);
  });

  test('setting the default clears the modified mark', () {
    settings.setValue(intDef, 7);
    settings.setValue(intDef, 5);
    expect(settings.isModified(intDef), isFalse);
  });

  test('reset restores one value', () {
    settings.setValue(intDef, 7);
    settings.setValue(boolDef, false);
    settings.reset(intDef);
    expect(settings.valueOf(intDef), 5);
    expect(settings.valueOf(boolDef), isFalse);
  });

  test('reset all restores every listed value', () {
    settings.setValue(intDef, 7);
    settings.setValue(boolDef, false);
    settings.resetAll([intDef, boolDef]);
    expect(settings.valueOf(intDef), 5);
    expect(settings.valueOf(boolDef), isTrue);
  });
}
