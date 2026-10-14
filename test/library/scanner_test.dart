import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/audio_file.dart';
import 'package:altynemel/library/scanner.dart';

import '../support/audio_fixtures.dart';

void main() {
  late Directory root;
  late Directory covers;

  setUp(() {
    root = Directory.systemTemp.createTempSync('altynemel_scan_');
    covers = Directory('${root.path}/_covers');
  });

  tearDown(() => root.deleteSync(recursive: true));

  ScanResult scan({Map<String, KnownFile> known = const {}}) {
    return scanLibrary(
      ScanRequest(
        root: '${root.path}/music',
        coversDirectory: covers.path,
        known: known,
      ),
    );
  }

  Directory music() =>
      Directory('${root.path}/music')..createSync(recursive: true);

  test('recognizes the six supported formats and ignores the rest', () {
    for (final name in [
      'a.mp3',
      'b.FLAC',
      'c.m4a',
      'd.aac',
      'e.ogg',
      'f.Opus',
      'g.wav',
    ]) {
      expect(isAudioFile(name), isTrue, reason: name);
    }
    for (final name in [
      'a.txt',
      'cover.jpg',
      'noextension',
      '.mp3',
      'a.mp3.bak',
    ]) {
      expect(isAudioFile(name), isFalse, reason: name);
    }
  });

  test('walks directories recursively and skips non-audio files', () {
    final dir = music();
    writeFile(dir, 'one.mp3', mp3Bytes(title: 'One'));
    writeFile(dir, 'deep/er/two.mp3', mp3Bytes(title: 'Two'));
    writeFile(dir, 'notes.txt', [1, 2, 3]);
    writeFile(dir, 'deep/art.jpg', [1, 2, 3]);
    final result = scan();
    expect(result.seen.length, 2);
    expect(result.changed.map((t) => t.title).toSet(), {'One', 'Two'});
  });

  test('reads tags including Cyrillic, Kazakh letters and diacritics', () {
    final dir = music();
    writeFile(
      dir,
      'a.mp3',
      mp3Bytes(
        title: 'Балбырауын',
        artist: 'Құрманғазы',
        album: 'Сарыарқа',
        albumArtist: 'Құрманғазы',
        trackNumber: '3',
      ),
    );
    writeFile(dir, 'b.mp3', mp3Bytes(title: 'Natt', artist: 'Bjørk Ødegård'));
    final byTitle = {for (final t in scan().changed) t.title: t};
    final a = byTitle['Балбырауын']!;
    expect(a.artist, 'Құрманғазы');
    expect(a.album, 'Сарыарқа');
    expect(a.albumArtist, 'Құрманғазы');
    expect(a.trackNumber, 3);
    expect(byTitle['Natt']!.artist, 'Bjørk Ødegård');
    expect(byTitle['Natt']!.album, isNull);
  });

  test('missing tags fall back to the file name and Unknown artist', () {
    final dir = music();
    writeFile(dir, 'My Song.mp3', mp3Bytes());
    writeFile(dir, 'broken.mp3', [1, 2, 3, 4]);
    final byTitle = {for (final t in scan().changed) t.title: t};
    expect(byTitle['My Song']!.artist, unknownArtist);
    expect(byTitle['broken']!.artist, unknownArtist);
    expect(byTitle['broken']!.durationMs, 0);
  });

  test('embedded cover wins over a cover file in the folder', () {
    final dir = music();
    writeFile(dir, 'a.mp3', mp3Bytes(title: 'A', picture: pngBytes));
    writeFile(dir, 'cover.jpg', [9, 9, 9]);
    final track = scan().changed.single;
    expect(track.coverPath, startsWith(covers.path));
    expect(track.coverPath, endsWith('.png'));
    expect(File(track.coverPath!).readAsBytesSync(), pngBytes);
  });

  test(
    'folder cover is used when nothing is embedded, in the documented order',
    () {
      final dir = music();
      writeFile(dir, 'x/a.mp3', mp3Bytes(title: 'A'));
      writeFile(dir, 'x/folder.jpg', [1]);
      writeFile(dir, 'x/Cover.PNG', [2]);
      writeFile(dir, 'y/b.mp3', mp3Bytes(title: 'B'));
      writeFile(dir, 'y/folder.jpg', [3]);
      writeFile(dir, 'z/c.mp3', mp3Bytes(title: 'C'));
      final byTitle = {for (final t in scan().changed) t.title: t};
      expect(byTitle['A']!.coverPath, endsWith('x/Cover.PNG'));
      expect(byTitle['B']!.coverPath, endsWith('y/folder.jpg'));
      expect(byTitle['C']!.coverPath, isNull);
    },
  );

  test('unchanged files are skipped and still reported as seen', () {
    final dir = music();
    final file = writeFile(dir, 'a.mp3', mp3Bytes(title: 'A'));
    final first = scan();
    final stat = file.statSync();
    final second = scan(
      known: {
        file.path: KnownFile(
          mtimeMs: stat.modified.millisecondsSinceEpoch,
          size: stat.size,
        ),
      },
    );
    expect(first.changed.length, 1);
    expect(second.changed, isEmpty);
    expect(second.seen, {file.path});
  });

  test('an unreadable or missing root yields no files', () {
    final result = scan();
    expect(result.seen, isEmpty);
  });
}
