import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/player/playback_persistence.dart';
import 'package:altynemel/storage/library_database.dart';

void main() {
  late LibraryDatabase db;
  late PlaybackPersistence persistence;

  setUp(() {
    db = LibraryDatabase.inMemory();
    persistence = PlaybackPersistence(db);
  });

  tearDown(() => db.close());

  test('load returns null when nothing was saved', () {
    expect(persistence.load(), isNull);
  });

  test('saved state is loaded back', () {
    persistence.save(
      const SavedPlayback(
        queue: {
          'ids': ['a', 'b'],
          'index': 1,
        },
        positionMs: 4200,
        volume: 35,
      ),
    );
    final loaded = persistence.load()!;
    expect(loaded.queue, {
      'ids': ['a', 'b'],
      'index': 1,
    });
    expect(loaded.positionMs, 4200);
    expect(loaded.volume, 35);
  });

  test('missing position and volume fall back to defaults', () {
    db.setSetting(PlaybackPersistence.key, '{"queue": {}}');
    final loaded = persistence.load()!;
    expect(loaded.positionMs, 0);
    expect(loaded.volume, 70);
  });

  test('invalid json is ignored', () {
    db.setSetting(PlaybackPersistence.key, 'not json');
    expect(persistence.load(), isNull);
  });

  test('json of the wrong shape is ignored', () {
    db.setSetting(PlaybackPersistence.key, '[1, 2]');
    expect(persistence.load(), isNull);
    db.setSetting(PlaybackPersistence.key, '{"volume": 10}');
    expect(persistence.load(), isNull);
  });
}
