import 'audio_file.dart';

class ScanOptions {
  const ScanOptions({
    this.extensions = audioExtensions,
    this.skipHidden = false,
    this.followLinks = false,
    this.excluded = const {},
  });

  final Set<String> extensions;
  final bool skipHidden;
  final bool followLinks;
  final Set<String> excluded;
}

Set<String> parseExtensions(String spec) {
  final found = {
    for (final part in spec.split(RegExp(r'[\s,;]+')))
      if (part.replaceAll('.', '').isNotEmpty)
        part.toLowerCase().replaceFirst(RegExp(r'^\.+'), ''),
  };
  return found.isEmpty ? audioExtensions : found;
}

Set<String> parseFolderNames(String spec) {
  return {
    for (final part in spec.split(RegExp(r'[,;]')))
      if (part.trim().isNotEmpty) part.trim().toLowerCase(),
  };
}
