import 'package:flutter/material.dart';

import 'app.dart';
import 'library/library_controller.dart';
import 'settings/app_settings.dart';
import 'settings/settings_persistence.dart';
import 'storage/app_directories.dart';
import 'storage/library_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(AltynemelApp(settings: settings, library: library));
}
