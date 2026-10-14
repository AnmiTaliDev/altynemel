import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

import '../library/scanner.dart';
import '../library/track.dart';

const int schemaVersion = 1;

class LibraryDatabase {
  LibraryDatabase._(this._db);

  factory LibraryDatabase.open(String path) {
    return LibraryDatabase._(sqlite3.open(path)).._migrate();
  }

  factory LibraryDatabase.inMemory() {
    return LibraryDatabase._(sqlite3.openInMemory()).._migrate();
  }

  final CommonDatabase _db;

  void _migrate() {
    _db.execute('PRAGMA foreign_keys = ON');
    if (_db.userVersion < 1) {
      _db.execute('''
        CREATE TABLE tracks (
          id INTEGER PRIMARY KEY,
          path TEXT NOT NULL UNIQUE,
          mtime_ms INTEGER NOT NULL,
          size INTEGER NOT NULL,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          album_artist TEXT,
          album TEXT,
          track_number INTEGER,
          disc_number INTEGER,
          duration_ms INTEGER NOT NULL,
          cover_path TEXT
        )
      ''');
      _db.execute('''
        CREATE TABLE likes (
          track_id INTEGER PRIMARY KEY REFERENCES tracks(id) ON DELETE CASCADE,
          liked_at INTEGER NOT NULL
        )
      ''');
      _db.execute('''
        CREATE TABLE playlists (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      _db.execute('''
        CREATE TABLE playlist_tracks (
          playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
          track_id INTEGER NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
          position INTEGER NOT NULL,
          PRIMARY KEY (playlist_id, position)
        )
      ''');
      _db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      _db.userVersion = 1;
    }
  }

  void close() => _db.close();

  Map<String, KnownFile> knownFiles() {
    final rows = _db.select('SELECT path, mtime_ms, size FROM tracks');
    return {
      for (final row in rows)
        row['path'] as String: KnownFile(
          mtimeMs: row['mtime_ms'] as int,
          size: row['size'] as int,
        ),
    };
  }

  void applyScan(ScanResult result) {
    _db.execute('BEGIN');
    try {
      final upsert = _db.prepare('''
        INSERT INTO tracks (path, mtime_ms, size, title, artist, album_artist,
          album, track_number, disc_number, duration_ms, cover_path)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(path) DO UPDATE SET
          mtime_ms = excluded.mtime_ms,
          size = excluded.size,
          title = excluded.title,
          artist = excluded.artist,
          album_artist = excluded.album_artist,
          album = excluded.album,
          track_number = excluded.track_number,
          disc_number = excluded.disc_number,
          duration_ms = excluded.duration_ms,
          cover_path = excluded.cover_path
      ''');
      for (final t in result.changed) {
        upsert.execute([
          t.path,
          t.mtimeMs,
          t.size,
          t.title,
          t.artist,
          t.albumArtist,
          t.album,
          t.trackNumber,
          t.discNumber,
          t.durationMs,
          t.coverPath,
        ]);
      }
      upsert.close();
      final remove = _db.prepare('DELETE FROM tracks WHERE path = ?');
      for (final path in knownFiles().keys) {
        if (!result.seen.contains(path)) remove.execute([path]);
      }
      remove.close();
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  List<Track> tracks() {
    final rows = _db.select('''
      SELECT id, path, title, artist, album_artist, album, track_number,
        disc_number, duration_ms, cover_path
      FROM tracks
    ''');
    return [for (final row in rows) _track(row)];
  }

  Track _track(Row row) {
    return Track(
      id: (row['id'] as int).toString(),
      path: row['path'] as String,
      title: row['title'] as String,
      artist: row['artist'] as String,
      albumArtist: row['album_artist'] as String?,
      album: row['album'] as String?,
      trackNumber: row['track_number'] as int?,
      discNumber: row['disc_number'] as int?,
      duration: Duration(milliseconds: row['duration_ms'] as int),
      coverPath: row['cover_path'] as String?,
    );
  }

  Set<String> likedIds() {
    final rows = _db.select('SELECT track_id FROM likes');
    return {for (final row in rows) (row['track_id'] as int).toString()};
  }

  void setLiked(String trackId, bool liked) {
    final id = int.parse(trackId);
    if (liked) {
      _db.execute(
        'INSERT OR IGNORE INTO likes (track_id, liked_at) VALUES (?, ?)',
        [id, DateTime.now().millisecondsSinceEpoch],
      );
    } else {
      _db.execute('DELETE FROM likes WHERE track_id = ?', [id]);
    }
  }

  List<StoredPlaylist> playlists() {
    final rows = _db.select(
      'SELECT id, name FROM playlists ORDER BY created_at, id',
    );
    return [
      for (final row in rows)
        StoredPlaylist(
          id: (row['id'] as int).toString(),
          name: row['name'] as String,
        ),
    ];
  }

  String createPlaylist(String name) {
    _db.execute('INSERT INTO playlists (name, created_at) VALUES (?, ?)', [
      name,
      DateTime.now().millisecondsSinceEpoch,
    ]);
    return _db.lastInsertRowId.toString();
  }

  void renamePlaylist(String playlistId, String name) {
    _db.execute('UPDATE playlists SET name = ? WHERE id = ?', [
      name,
      int.parse(playlistId),
    ]);
  }

  void deletePlaylist(String playlistId) {
    _db.execute('DELETE FROM playlists WHERE id = ?', [int.parse(playlistId)]);
  }

  void addToPlaylist(String playlistId, String trackId) {
    final id = int.parse(playlistId);
    final next =
        _db.select(
              'SELECT COALESCE(MAX(position), -1) + 1 AS next FROM playlist_tracks WHERE playlist_id = ?',
              [id],
            ).first['next']
            as int;
    _db.execute(
      'INSERT INTO playlist_tracks (playlist_id, track_id, position) VALUES (?, ?, ?)',
      [id, int.parse(trackId), next],
    );
  }

  void removeFromPlaylist(String playlistId, String trackId) {
    _db.execute(
      'DELETE FROM playlist_tracks WHERE playlist_id = ? AND track_id = ?',
      [int.parse(playlistId), int.parse(trackId)],
    );
  }

  List<String> playlistTrackIds(String playlistId) {
    final rows = _db.select(
      'SELECT track_id FROM playlist_tracks WHERE playlist_id = ? ORDER BY position',
      [int.parse(playlistId)],
    );
    return [for (final row in rows) (row['track_id'] as int).toString()];
  }

  Map<String, String> settings() {
    final rows = _db.select('SELECT key, value FROM settings');
    return {
      for (final row in rows) row['key'] as String: row['value'] as String,
    };
  }

  void setSetting(String key, String value) {
    _db.execute(
      'INSERT INTO settings (key, value) VALUES (?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      [key, value],
    );
  }
}

class StoredPlaylist {
  const StoredPlaylist({required this.id, required this.name});

  final String id;
  final String name;
}
