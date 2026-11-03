import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/settings_persistence.dart';
import 'package:altynemel/storage/library_database.dart';

void main() {
  late LibraryDatabase db;

  setUp(() => db = LibraryDatabase.inMemory());
  tearDown(() => db.close());

  test('plain settings count as set up', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    expect(settings.setupCompleted, isTrue);
  });

  test('an empty database is a fresh install that needs the wizard', () {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    SettingsPersistence(settings, db).restore();
    expect(settings.setupCompleted, isFalse);
  });

  test('a database with older settings is treated as already set up', () {
    db.setSetting('theme', 'day');
    final settings = AppSettings();
    addTearDown(settings.dispose);
    SettingsPersistence(settings, db).restore();
    expect(settings.setupCompleted, isTrue);
  });

  test('a stored flag wins over the guess', () {
    db.setSetting('theme', 'day');
    db.setSetting('setupCompleted', 'false');
    final settings = AppSettings();
    addTearDown(settings.dispose);
    SettingsPersistence(settings, db).restore();
    expect(settings.setupCompleted, isFalse);
  });

  test('finishing the wizard is remembered', () {
    final first = AppSettings();
    addTearDown(first.dispose);
    final persistence = SettingsPersistence(first, db)
      ..restore()
      ..attach();
    expect(first.setupCompleted, isFalse);
    first.setSetupCompleted(true);
    persistence.detach();
    final second = AppSettings();
    addTearDown(second.dispose);
    SettingsPersistence(second, db).restore();
    expect(second.setupCompleted, isTrue);
  });

  test('a half finished wizard comes back on the next launch', () {
    final first = AppSettings();
    addTearDown(first.dispose);
    final persistence = SettingsPersistence(first, db)
      ..restore()
      ..attach();
    first.setTheme(ThemeChoice.day);
    persistence.detach();
    final second = AppSettings();
    addTearDown(second.dispose);
    SettingsPersistence(second, db).restore();
    expect(second.theme, ThemeChoice.day);
    expect(second.setupCompleted, isFalse);
  });
}
