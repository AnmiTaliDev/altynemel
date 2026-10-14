import 'package:flutter/material.dart';

import 'package:altynemel/app.dart';
import 'package:altynemel/library/library_controller.dart';
import 'package:altynemel/library/library_scope.dart';
import 'package:altynemel/library/scanner.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/app_settings_scope.dart';
import 'package:altynemel/storage/library_database.dart';
import 'package:altynemel/theme/themes.dart';

const sharedPlaylistName = 'Shared with me';

const fixtureTracks = [
  ScannedTrack(
    path: '/music/single/fading memories.mp3',
    mtimeMs: 1,
    size: 1,
    title: 'fading memories',
    artist: 'june lu, sløwmind',
    durationMs: 147000,
  ),
  ScannedTrack(
    path: '/music/saryarka/01.mp3',
    mtimeMs: 1,
    size: 1,
    title: 'Балбырауын',
    artist: 'Құрманғазы',
    album: 'Сарыарқа',
    trackNumber: 1,
    durationMs: 252000,
  ),
  ScannedTrack(
    path: '/music/saryarka/02.mp3',
    mtimeMs: 1,
    size: 1,
    title: 'Адай',
    artist: 'Құрманғазы',
    album: 'Сарыарқа',
    trackNumber: 2,
    durationMs: 220000,
  ),
  ScannedTrack(
    path: '/music/stille/01.flac',
    mtimeMs: 1,
    size: 1,
    title: 'Natt over fjorden',
    artist: 'Bjørk Ødegård',
    album: 'Stille',
    trackNumber: 1,
    durationMs: 303000,
  ),
];

class TestLibrary {
  TestLibrary({bool empty = false}) {
    if (!empty) {
      database.applyScan(
        ScanResult(
          changed: fixtureTracks,
          seen: {for (final t in fixtureTracks) t.path},
        ),
      );
      final playlistId = database.createPlaylist(sharedPlaylistName);
      database.addToPlaylist(playlistId, database.tracks().first.id);
    }
    library = LibraryController(
      database: database,
      settings: settings,
      coversDirectory: '/nonexistent/covers',
    );
  }

  final LibraryDatabase database = LibraryDatabase.inMemory();
  final AppSettings settings = AppSettings();
  late final LibraryController library;

  void dispose() {
    library.dispose();
    settings.dispose();
    database.close();
  }

  Widget wrap(Widget home, {AltynemelThemeId theme = AltynemelThemeId.night}) {
    return AppSettingsScope(
      settings: settings,
      child: LibraryScope(
        library: library,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildTheme(theme),
          home: Scaffold(body: home),
        ),
      ),
    );
  }

  Widget app() => AltynemelApp(settings: settings, library: library);
}
