import 'package:flutter/foundation.dart';

import 'setting_def.dart';

enum ThemeChoice { system, night, day, contrast }

enum RescanInterval { minutes5, minutes15, hour1, hours6, off }

enum AlbumOrder { discAndTrack, fileName }

class AppSettings extends ChangeNotifier {
  ThemeChoice _theme = ThemeChoice.system;
  bool _reduceMotion = false;
  bool _gapless = true;
  bool _crossfade = false;
  int _volumeStep = 5;
  RescanInterval _rescanInterval = RescanInterval.minutes15;
  bool _splitArtists = true;
  AlbumOrder _albumOrder = AlbumOrder.discAndTrack;
  String? _libraryFolder;
  final Map<String, Object> _values = {};

  ThemeChoice get theme => _theme;
  bool get reduceMotion => _reduceMotion;
  bool get gapless => _gapless;
  bool get crossfade => _crossfade;
  int get volumeStep => _volumeStep;
  RescanInterval get rescanInterval => _rescanInterval;
  bool get splitArtists => _splitArtists;
  AlbumOrder get albumOrder => _albumOrder;
  String? get libraryFolder => _libraryFolder;

  void setTheme(ThemeChoice value) => _update(() => _theme = value);
  void setReduceMotion(bool value) => _update(() => _reduceMotion = value);
  void setGapless(bool value) => _update(() => _gapless = value);
  void setCrossfade(bool value) => _update(() => _crossfade = value);
  void setVolumeStep(int value) => _update(() => _volumeStep = value);
  void setRescanInterval(RescanInterval value) =>
      _update(() => _rescanInterval = value);
  void setSplitArtists(bool value) => _update(() => _splitArtists = value);
  void setAlbumOrder(AlbumOrder value) => _update(() => _albumOrder = value);
  void setLibraryFolder(String? value) => _update(() => _libraryFolder = value);

  T valueOf<T extends Object>(SettingDef<T> def) {
    return (_values[def.key] as T?) ?? def.defaultValue;
  }

  bool isModified(SettingDef<Object> def) => _values.containsKey(def.key);

  void setValue<T extends Object>(SettingDef<T> def, T value) {
    final next = def.normalize(value);
    if (valueOf(def) == next) return;
    _update(() {
      if (next == def.defaultValue) {
        _values.remove(def.key);
      } else {
        _values[def.key] = next;
      }
    });
  }

  void reset(SettingDef<Object> def) {
    if (!isModified(def)) return;
    _update(() => _values.remove(def.key));
  }

  void resetAll(Iterable<SettingDef<Object>> defs) {
    if (!defs.any(isModified)) return;
    _update(() {
      for (final def in defs) {
        _values.remove(def.key);
      }
    });
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }
}
