import 'package:permission_handler/permission_handler.dart';

const String androidMusicFolder = '/storage/emulated/0/Music';

Future<bool> requestAndroidAudioAccess() async {
  if ((await Permission.audio.request()).isGranted) return true;
  return (await Permission.storage.request()).isGranted;
}

Future<void> requestAndroidNotificationAccess() async {
  await Permission.notification.request();
}
