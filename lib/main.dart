import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'integration/media_session.dart';
import 'integration/window_service.dart';
import 'library/library_controller.dart';
import 'player/playback_controller.dart';
import 'player/playback_persistence.dart';
import 'settings/app_settings.dart';
import 'settings/settings_persistence.dart';
import 'storage/app_directories.dart';
import 'storage/library_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final directory = appDataDirectory();
  final database = LibraryDatabase.open('${directory.path}/library.db');
  final settings = AppSettings();
  final persistence = SettingsPersistence(settings, database)..restore();
  persistence.attach();
  final library = LibraryController(
    database: database,
    settings: settings,
    coversDirectory: '${directory.path}/covers',
  )..start();
  final playback = PlaybackController(
    settings: settings,
    persistence: PlaybackPersistence(database),
  );
  await playback.restore(library.trackById);
  if (mediaSessionSupported) await initMediaSession(playback);
  WindowService? window;
  if (Platform.isLinux || Platform.isMacOS) {
    window = WindowService(
      onClosing: () async {
        playback.persist();
      },
    );
    await window.init();
  }
  runApp(
    AltynemelApp(
      settings: settings,
      library: library,
      playback: playback,
      window: window,
    ),
  );
}
