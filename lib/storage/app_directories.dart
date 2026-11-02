import 'dart:io';

import 'package:path_provider/path_provider.dart';

const String appDirectoryName = 'dev.anmitali.altynemel';

Future<Directory> appDataDirectory() async {
  if (Platform.isAndroid) return getApplicationSupportDirectory();
  final env = Platform.environment;
  final home = env['HOME'];
  final String base;
  if (Platform.isMacOS) {
    base = '$home/Library/Application Support';
  } else {
    final xdg = env['XDG_DATA_HOME'];
    base = (xdg != null && xdg.isNotEmpty) ? xdg : '$home/.local/share';
  }
  final directory = Directory('$base/$appDirectoryName');
  directory.createSync(recursive: true);
  return directory;
}
