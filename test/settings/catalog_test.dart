import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/setting_def.dart';
import 'package:altynemel/settings/settings_persistence.dart';
import 'package:altynemel/storage/library_database.dart';

Object otherValue(SettingDef<Object> def) {
  return switch (def) {
    IntSetting() => def.defaultValue == def.max ? def.min : def.max,
    DoubleSetting() => def.defaultValue == def.max ? def.min : def.max,
    BoolSetting() => !def.defaultValue,
    EnumSetting<Enum>() => def.values.firstWhere(
      (value) => value != def.defaultValue,
    ),
    TextSetting() => '${def.defaultValue}x',
    _ => throw StateError('unknown setting type ${def.runtimeType}'),
  };
}

void main() {
  test('the catalog has many settings in every group', () {
    expect(allSettings.length, greaterThan(40));
    for (final group in SettingGroup.values) {
      expect(
        allSettings.where((def) => def.group == group),
        isNotEmpty,
        reason: group.name,
      );
    }
  });

  test('keys are unique and texts are filled in', () {
    final keys = allSettings.map((def) => def.key).toList();
    expect(keys.toSet().length, keys.length);
    for (final def in allSettings) {
      expect(def.label.trim(), isNotEmpty, reason: def.key);
      expect(def.hint.trim(), isNotEmpty, reason: def.key);
    }
  });

  test('every default is valid and survives its own encoding', () {
    for (final def in allSettings) {
      expect(
        def.normalize(def.defaultValue),
        def.defaultValue,
        reason: def.key,
      );
      expect(
        def.decode(def.encode(def.defaultValue)),
        def.defaultValue,
        reason: def.key,
      );
    }
  });

  test('numeric ranges are consistent', () {
    for (final def in allSettings) {
      if (def is IntSetting) {
        expect(def.min, lessThan(def.max), reason: def.key);
        expect(def.step, greaterThan(0), reason: def.key);
        expect(def.defaultValue, inInclusiveRange(def.min, def.max));
      }
      if (def is DoubleSetting) {
        expect(def.min, lessThan(def.max), reason: def.key);
        expect(def.step, greaterThan(0), reason: def.key);
        expect(def.defaultValue, inInclusiveRange(def.min, def.max));
      }
    }
  });

  test('choices have a label for every value', () {
    for (final def in allSettings) {
      if (def is EnumSetting<Enum>) {
        expect(def.values, contains(def.defaultValue), reason: def.key);
        for (final value in def.values) {
          expect(def.labels[value], isNotNull, reason: '${def.key} $value');
        }
      }
    }
  });

  test('every setting round trips through the database', () {
    final db = LibraryDatabase.inMemory();
    addTearDown(db.close);
    final first = AppSettings();
    addTearDown(first.dispose);
    final persistence = SettingsPersistence(first, db)..attach();
    final changed = <SettingDef<Object>, Object>{};
    for (final def in allSettings) {
      final value = otherValue(def);
      first.setValue(def, value);
      changed[def] = first.valueOf(def);
    }
    persistence.detach();
    final second = AppSettings();
    addTearDown(second.dispose);
    SettingsPersistence(second, db).restore();
    for (final entry in changed.entries) {
      expect(second.valueOf(entry.key), entry.value, reason: entry.key.key);
      expect(second.isModified(entry.key), isTrue, reason: entry.key.key);
    }
  });

  test('reset all brings back every default', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    for (final def in allSettings) {
      settings.setValue(def, otherValue(def));
    }
    expect(allSettings.every(settings.isModified), isTrue);
    settings.resetAll(allSettings);
    for (final def in allSettings) {
      expect(settings.valueOf(def), def.defaultValue, reason: def.key);
    }
  });
}
