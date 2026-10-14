import 'dart:convert';

import '../storage/library_database.dart';

class SavedPlayback {
  const SavedPlayback({
    required this.queue,
    required this.positionMs,
    required this.volume,
  });

  final Map<String, Object?> queue;
  final int positionMs;
  final int volume;
}

class PlaybackPersistence {
  PlaybackPersistence(this._database);

  final LibraryDatabase _database;

  static const String key = 'playback';

  void save(SavedPlayback state) {
    _database.setSetting(
      key,
      jsonEncode({
        'queue': state.queue,
        'positionMs': state.positionMs,
        'volume': state.volume,
      }),
    );
  }

  SavedPlayback? load() {
    final raw = _database.settings()[key];
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return SavedPlayback(
        queue: (json['queue'] as Map).cast<String, Object?>(),
        positionMs: json['positionMs'] as int? ?? 0,
        volume: json['volume'] as int? ?? 70,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
