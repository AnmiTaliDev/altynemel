const audioExtensions = <String>{
  'mp3',
  'flac',
  'm4a',
  'aac',
  'ogg',
  'opus',
  'wav',
};

String extensionOf(String path) {
  final name = fileNameOf(path);
  final dot = name.lastIndexOf('.');
  if (dot <= 0) return '';
  return name.substring(dot + 1).toLowerCase();
}

String fileNameOf(String path) {
  final slash = path.lastIndexOf('/');
  return slash < 0 ? path : path.substring(slash + 1);
}

String directoryOf(String path) {
  final slash = path.lastIndexOf('/');
  return slash < 0 ? '' : path.substring(0, slash);
}

String stemOf(String path) {
  final name = fileNameOf(path);
  final dot = name.lastIndexOf('.');
  return dot <= 0 ? name : name.substring(0, dot);
}

bool isAudioFile(String path) => audioExtensions.contains(extensionOf(path));
