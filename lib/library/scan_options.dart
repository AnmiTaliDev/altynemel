import 'audio_file.dart';

class ScanOptions {
  const ScanOptions({this.extensions = audioExtensions});

  final Set<String> extensions;
}

Set<String> parseExtensions(String spec) {
  final found = {
    for (final part in spec.split(RegExp(r'[\s,;]+')))
      if (part.replaceAll('.', '').isNotEmpty)
        part.toLowerCase().replaceFirst(RegExp(r'^\.+'), ''),
  };
  return found.isEmpty ? audioExtensions : found;
}
