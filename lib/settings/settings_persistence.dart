import '../storage/library_database.dart';
import 'app_settings.dart';
import 'catalog.dart';
import 'setting_def.dart';

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

bool _bool(String? value, bool fallback) {
  if (value == 'true') return true;
  if (value == 'false') return false;
  return fallback;
}

const String definitionKeyPrefix = 's.';

class SettingsPersistence {
  SettingsPersistence(
    this._settings,
    this._database, {
    this.definitions = allSettings,
  });

  final AppSettings _settings;
  final LibraryDatabase _database;
  final List<SettingDef<Object>> definitions;

  void restore() {
    final stored = _database.settings();
    final defaults = AppSettings();
    _settings.setTheme(
      _enumByName(ThemeChoice.values, stored['theme'], defaults.theme),
    );
    _settings.setReduceMotion(
      _bool(stored['reduceMotion'], defaults.reduceMotion),
    );
    _settings.setGapless(_bool(stored['gapless'], defaults.gapless));
    _settings.setCrossfade(_bool(stored['crossfade'], defaults.crossfade));
    _settings.setVolumeStep(
      int.tryParse(stored['volumeStep'] ?? '') ?? defaults.volumeStep,
    );
    _settings.setRescanInterval(
      _enumByName(
        RescanInterval.values,
        stored['rescanInterval'],
        defaults.rescanInterval,
      ),
    );
    _settings.setSplitArtists(
      _bool(stored['splitArtists'], defaults.splitArtists),
    );
    _settings.setAlbumOrder(
      _enumByName(AlbumOrder.values, stored['albumOrder'], defaults.albumOrder),
    );
    _settings.setLibraryFolder(stored['libraryFolder']);
    _settings.setSetupCompleted(
      _bool(stored['setupCompleted'], stored.isNotEmpty),
    );
    for (final def in definitions) {
      final raw = stored['$definitionKeyPrefix${def.key}'];
      if (raw == null) continue;
      final value = def.decode(raw);
      if (value != null) _settings.setValue(def, value);
    }
    defaults.dispose();
  }

  void attach() => _settings.addListener(_save);

  void detach() => _settings.removeListener(_save);

  void _save() {
    _database.setSetting('theme', _settings.theme.name);
    _database.setSetting('reduceMotion', '${_settings.reduceMotion}');
    _database.setSetting('gapless', '${_settings.gapless}');
    _database.setSetting('crossfade', '${_settings.crossfade}');
    _database.setSetting('volumeStep', '${_settings.volumeStep}');
    _database.setSetting('rescanInterval', _settings.rescanInterval.name);
    _database.setSetting('splitArtists', '${_settings.splitArtists}');
    _database.setSetting('albumOrder', _settings.albumOrder.name);
    _database.setSetting('setupCompleted', '${_settings.setupCompleted}');
    final folder = _settings.libraryFolder;
    if (folder != null) _database.setSetting('libraryFolder', folder);
    for (final def in definitions) {
      _database.setSetting(
        '$definitionKeyPrefix${def.key}',
        def.encode(_settings.valueOf(def)),
      );
    }
  }
}
