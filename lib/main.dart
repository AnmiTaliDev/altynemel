import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'integration/android_media_session.dart';
import 'integration/android_storage.dart';
import 'integration/global_shortcuts.dart';
import 'integration/mpris.dart';
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
  final directory = await appDataDirectory();
  final database = LibraryDatabase.open('${directory.path}/library.db');
  final settings = AppSettings();
  final persistence = SettingsPersistence(settings, database)..restore();
  persistence.attach();
  if (Platform.isAndroid) {
    final granted = await requestAndroidAudioAccess();
    if (granted && settings.libraryFolder == null) {
      settings.setLibraryFolder(androidMusicFolder);
    }
    await requestAndroidNotificationAccess();
  }
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
  if (Platform.isAndroid) await startAndroidMediaSession(playback);
  if (Platform.isLinux) {
    unawaited(GlobalShortcuts(actions: shortcutActions(playback)).start());
  }
  WindowService? window;
  if (Platform.isLinux || Platform.isMacOS) {
    window = WindowService(
      onClosing: () async {
        playback.persist();
      },
    );
    await window.init();
  }
  if (Platform.isLinux && window != null) {
    unawaited(
      MprisService(
        playback: playback,
        onRaise: window.raise,
        onQuit: window.close,
      ).start(),
    );
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
