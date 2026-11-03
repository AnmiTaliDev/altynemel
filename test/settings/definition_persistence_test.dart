import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/setting_def.dart';
import 'package:altynemel/settings/settings_persistence.dart';
import 'package:altynemel/storage/library_database.dart';

enum Mode { first, second }

const intDef = IntSetting(
  key: 'i',
  group: SettingGroup.playback,
  label: 'Int',
  hint: '',
  defaultValue: 5,
  min: 1,
  max: 10,
);

const enumDef = EnumSetting<Mode>(
  key: 'e',
  group: SettingGroup.library,
  label: 'Enum',
  hint: '',
  defaultValue: Mode.first,
  values: Mode.values,
  labels: {Mode.first: 'First', Mode.second: 'Second'},
);

const defs = <SettingDef<Object>>[intDef, enumDef];

void main() {
  late LibraryDatabase db;

  setUp(() => db = LibraryDatabase.inMemory());
  tearDown(() => db.close());

  test('definition values round trip through the database', () {
    final first = AppSettings();
    final persistence = SettingsPersistence(first, db, definitions: defs)
      ..attach();
    first.setValue(intDef, 8);
    first.setValue(enumDef, Mode.second);
    persistence.detach();
    final second = AppSettings();
    SettingsPersistence(second, db, definitions: defs).restore();
    expect(second.valueOf(intDef), 8);
    expect(second.valueOf(enumDef), Mode.second);
    first.dispose();
    second.dispose();
  });

  test('missing and invalid stored values keep the defaults', () {
    db.setSetting('${definitionKeyPrefix}i', 'many');
    db.setSetting('${definitionKeyPrefix}e', 'third');
    final settings = AppSettings();
    SettingsPersistence(settings, db, definitions: defs).restore();
    expect(settings.valueOf(intDef), 5);
    expect(settings.valueOf(enumDef), Mode.first);
    settings.dispose();
  });

  test('stored numbers are clamped on restore', () {
    db.setSetting('${definitionKeyPrefix}i', '500');
    final settings = AppSettings();
    SettingsPersistence(settings, db, definitions: defs).restore();
    expect(settings.valueOf(intDef), 10);
    settings.dispose();
  });
}
