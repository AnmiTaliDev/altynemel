import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/scanner.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/settings_persistence.dart';
import 'package:altynemel/storage/library_database.dart';

ScannedTrack scanned(
  String path, {
  String title = 'T',
  int mtime = 1,
  int size = 1,
}) {
  return ScannedTrack(
    path: path,
    mtimeMs: mtime,
    size: size,
    title: title,
    artist: 'A',
    durationMs: 1000,
  );
}

ScanResult result(List<ScannedTrack> tracks, [Set<String>? seen]) {
  return ScanResult(
    changed: tracks,
    seen: seen ?? {for (final t in tracks) t.path},
  );
}

void main() {
  late LibraryDatabase db;

  setUp(() => db = LibraryDatabase.inMemory());
  tearDown(() => db.close());

  test('stores and reads tracks', () {
    db.applyScan(result([scanned('/m/a.mp3', title: 'Балбырауын')]));
    final track = db.tracks().single;
    expect(track.title, 'Балбырауын');
    expect(track.duration, const Duration(seconds: 1));
    expect(db.knownFiles().keys, ['/m/a.mp3']);
  });

  test('updates a changed file in place and keeps its id', () {
    db.applyScan(result([scanned('/m/a.mp3')]));
    final id = db.tracks().single.id;
    db.applyScan(result([scanned('/m/a.mp3', title: 'New', mtime: 2)]));
    final track = db.tracks().single;
    expect(track.id, id);
    expect(track.title, 'New');
  });

  test('removes files that were not seen', () {
    db.applyScan(result([scanned('/m/a.mp3'), scanned('/m/b.mp3')]));
    db.applyScan(result([], {'/m/a.mp3'}));
    expect(db.tracks().map((t) => t.path), ['/m/a.mp3']);
  });

  test('likes are stored and cascade when a track disappears', () {
    db.applyScan(result([scanned('/m/a.mp3')]));
    final id = db.tracks().single.id;
    db.setLiked(id, true);
    db.setLiked(id, true);
    expect(db.likedIds(), {id});
    db.setLiked(id, false);
    expect(db.likedIds(), isEmpty);
    db.setLiked(id, true);
    db.applyScan(result([], {}));
    expect(db.likedIds(), isEmpty);
  });

  test('playlists keep order and cascade with their tracks', () {
    db.applyScan(result([scanned('/m/a.mp3'), scanned('/m/b.mp3')]));
    final ids = db.tracks().map((t) => t.id).toList();
    final playlist = db.createPlaylist('Shared with me');
    db.addToPlaylist(playlist, ids[1]);
    db.addToPlaylist(playlist, ids[0]);
    expect(db.playlistTrackIds(playlist), [ids[1], ids[0]]);
    expect(db.playlists().single.name, 'Shared with me');
    db.renamePlaylist(playlist, 'Renamed');
    expect(db.playlists().single.name, 'Renamed');
    db.applyScan(result([], {'/m/a.mp3'}));
    expect(db.playlistTrackIds(playlist), [ids[0]]);
    db.deletePlaylist(playlist);
    expect(db.playlists(), isEmpty);
  });

  test('settings round trip through persistence', () {
    final first = AppSettings();
    final persistence = SettingsPersistence(first, db)..attach();
    first.setTheme(ThemeChoice.contrast);
    first.setVolumeStep(10);
    first.setGapless(false);
    first.setRescanInterval(RescanInterval.hour1);
    first.setAlbumOrder(AlbumOrder.fileName);
    first.setLibraryFolder('/music');
    persistence.detach();
    final second = AppSettings();
    SettingsPersistence(second, db).restore();
    expect(second.theme, ThemeChoice.contrast);
    expect(second.volumeStep, 10);
    expect(second.gapless, isFalse);
    expect(second.rescanInterval, RescanInterval.hour1);
    expect(second.albumOrder, AlbumOrder.fileName);
    expect(second.libraryFolder, '/music');
    first.dispose();
    second.dispose();
  });

  test('restore keeps defaults for unknown or missing values', () {
    db.setSetting('theme', 'neon');
    db.setSetting('volumeStep', 'many');
    final settings = AppSettings();
    SettingsPersistence(settings, db).restore();
    expect(settings.theme, ThemeChoice.system);
    expect(settings.volumeStep, 5);
    expect(settings.libraryFolder, isNull);
    settings.dispose();
  });
}
