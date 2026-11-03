import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/audio_file.dart';
import 'package:altynemel/library/scan_options.dart';
import 'package:altynemel/library/scanner.dart';

import '../support/audio_fixtures.dart';

void main() {
  test('extensions are lower cased, deduplicated and stripped of dots', () {
    expect(parseExtensions('MP3, .Flac;ogg  wav,,mp3'), {
      'mp3',
      'flac',
      'ogg',
      'wav',
    });
  });

  test('an empty list falls back to the default formats', () {
    expect(parseExtensions(' , ; '), audioExtensions);
    expect(parseExtensions(''), audioExtensions);
  });

  test('isAudioFile honours a custom set', () {
    expect(isAudioFile('a.mp3', {'ogg'}), isFalse);
    expect(isAudioFile('a.OGG', {'ogg'}), isTrue);
    expect(isAudioFile('a.mp3'), isTrue);
  });

  test('the scanner only picks the configured extensions', () {
    final root = Directory.systemTemp.createTempSync('altynemel_opts_');
    addTearDown(() => root.deleteSync(recursive: true));
    final music = Directory('${root.path}/music')..createSync();
    writeFile(music, 'a.mp3', mp3Bytes(title: 'A'));
    writeFile(music, 'b.ogg', mp3Bytes(title: 'B'));
    final files = findAudioFiles(
      music,
      ScanOptions(extensions: parseExtensions('ogg')),
    );
    expect(files.map((f) => fileNameOf(f.path)), ['b.ogg']);
    expect(findAudioFiles(music).length, 2);
  });

  test('hidden folders are skipped only on request', () {
    final root = Directory.systemTemp.createTempSync('altynemel_hidden_');
    addTearDown(() => root.deleteSync(recursive: true));
    final music = Directory('${root.path}/music')..createSync();
    writeFile(music, 'a.mp3', mp3Bytes(title: 'A'));
    writeFile(music, '.trash/b.mp3', mp3Bytes(title: 'B'));
    writeFile(music, 'sub/.cache/c.mp3', mp3Bytes(title: 'C'));
    writeFile(music, 'sub/d.mp3', mp3Bytes(title: 'D'));
    expect(findAudioFiles(music).length, 4);
    final names = findAudioFiles(
      music,
      const ScanOptions(skipHidden: true),
    ).map((f) => fileNameOf(f.path));
    expect(names, ['a.mp3', 'd.mp3']);
  });
}
