import 'audio_file.dart';

const defaultCoverNames = ['cover.jpg', 'cover.png', 'folder.jpg'];

class ScanOptions {
  const ScanOptions({
    this.extensions = audioExtensions,
    this.skipHidden = false,
    this.followLinks = false,
    this.excluded = const {},
    this.coverNames = defaultCoverNames,
  });

  final Set<String> extensions;
  final bool skipHidden;
  final bool followLinks;
  final Set<String> excluded;
  final List<String> coverNames;
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

List<String> parseCoverNames(String spec) {
  final names = <String>[];
  for (final part in spec.split(RegExp(r'[,;]'))) {
    final name = part.trim().toLowerCase();
    if (name.isNotEmpty && !names.contains(name)) names.add(name);
  }
  return names.isEmpty ? defaultCoverNames : names;
}
