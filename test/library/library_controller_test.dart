import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/library_controller.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/storage/library_database.dart';

import '../support/audio_fixtures.dart';

Future<void> until(bool Function() condition) async {
  for (var i = 0; i < 200 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}

void main() {
  late Directory root;
  late Directory music;
  late LibraryDatabase db;
  late AppSettings settings;
  late LibraryController controller;

  setUp(() {
    root = Directory.systemTemp.createTempSync('altynemel_ctrl_');
    music = Directory('${root.path}/music')..createSync();
    db = LibraryDatabase.inMemory();
    settings = AppSettings();
    controller = LibraryController(
      database: db,
      settings: settings,
      coversDirectory: '${root.path}/covers',
    );
  });

  tearDown(() {
    controller.dispose();
    settings.dispose();
    db.close();
    root.deleteSync(recursive: true);
  });

  test('choosing a folder scans it and builds albums and artists', () async {
    writeFile(
      music,
      'a.mp3',
      mp3Bytes(title: 'One', artist: 'X, Y', album: 'Alb', trackNumber: '1'),
    );
    writeFile(
      music,
      'b.mp3',
      mp3Bytes(title: 'Two', artist: 'X', album: 'Alb', trackNumber: '2'),
    );
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 2);
    expect(controller.tracks.map((t) => t.title), ['One', 'Two']);
    expect(controller.albums.single.trackCount, 2);
    expect(
      {for (final a in controller.artists) a.name: a.trackCount},
      {'X': 2, 'Y': 1},
    );
    expect(controller.scanning, isFalse);
    expect(controller.error, isNull);
  });

  test('rescan picks up added and removed files', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'One'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 1);
    writeFile(music, 'b.mp3', mp3Bytes(title: 'Two'));
    File('${music.path}/a.mp3').deleteSync();
    await controller.scan();
    expect(controller.tracks.map((t) => t.title), ['Two']);
  });

  test('a missing folder reports an error and keeps the index', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'One'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 1);
    music.deleteSync(recursive: true);
    await controller.scan();
    expect(controller.error, isNotNull);
    expect(controller.tracks.length, 1);
  });

  test('split artists setting regroups without rescanning', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'One', artist: 'X, Y'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 1);
    expect(controller.artists.length, 2);
    settings.setSplitArtists(false);
    expect(controller.artists.single.name, 'X, Y');
  });

  test('album order setting changes track order', () async {
    writeFile(
      music,
      'a.mp3',
      mp3Bytes(title: 'Second', album: 'Alb', trackNumber: '2'),
    );
    writeFile(
      music,
      'b.mp3',
      mp3Bytes(title: 'First', album: 'Alb', trackNumber: '1'),
    );
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 2);
    expect(controller.tracks.map((t) => t.title), ['First', 'Second']);
    settings.setAlbumOrder(AlbumOrder.fileName);
    expect(controller.tracks.map((t) => t.title), ['Second', 'First']);
  });

  test('likes and playlists go through the controller', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'One'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 1);
    final id = controller.tracks.single.id;
    controller.setLiked(id, true);
    expect(controller.isLiked(id), isTrue);
    expect(controller.likedTracks.single.id, id);
    final playlist = controller.createPlaylist('Mine');
    controller.addToPlaylist(playlist, id);
    expect(controller.playlistTracks(playlist).single.id, id);
    expect(controller.playlists.single.name, 'Mine');
  });

  test('changing the file types rescans the library', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'A', album: 'X'));
    writeFile(music, 'b.ogg', mp3Bytes(title: 'B', album: 'X'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 2);
    settings.setValue(scanExtensions, 'ogg');
    await until(() => controller.tracks.length == 1);
    expect(controller.tracks.single.path, endsWith('b.ogg'));
    settings.reset(scanExtensions);
    await until(() => controller.tracks.length == 2);
  });

  test('skipping hidden folders rescans the library', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'A', album: 'X'));
    writeFile(music, '.hidden/b.mp3', mp3Bytes(title: 'B', album: 'X'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 2);
    settings.setValue(skipHiddenFolders, true);
    await until(() => controller.tracks.length == 1);
  });

  test('start scans the folder by default', () async {
    writeFile(music, 'a.mp3', mp3Bytes(title: 'A', album: 'X'));
    settings.setLibraryFolder(music.path);
    await until(() => controller.tracks.length == 1);
    final fresh = LibraryController(
      database: LibraryDatabase.inMemory(),
      settings: settings,
      coversDirectory: '${root.path}/covers2',
    )..start();
    addTearDown(fresh.dispose);
    await until(() => fresh.tracks.length == 1);
  });

  test(
    'start leaves the library alone when scanning on start is off',
    () async {
      writeFile(music, 'a.mp3', mp3Bytes(title: 'A', album: 'X'));
      settings.setValue(rescanOnStart, false);
      settings.setLibraryFolder(music.path);
      final fresh = LibraryController(
        database: LibraryDatabase.inMemory(),
        settings: settings,
        coversDirectory: '${root.path}/covers3',
      );
      addTearDown(fresh.dispose);
      fresh.start();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(fresh.scanning, isFalse);
      expect(fresh.tracks, isEmpty);
    },
  );

  test('a timer runs for a periodic interval and stops for never', () {
    settings.setLibraryFolder(music.path);
    expect(controller.rescanScheduled, isTrue);
    settings.setRescanInterval(RescanInterval.off);
    expect(controller.rescanScheduled, isFalse);
    settings.setRescanInterval(RescanInterval.hours6);
    expect(controller.rescanScheduled, isTrue);
  });

  test('the new intervals survive a restart', () {
    expect(rescanDurations[RescanInterval.hours6], const Duration(hours: 6));
    expect(rescanDurations.containsKey(RescanInterval.off), isFalse);
  });
}
