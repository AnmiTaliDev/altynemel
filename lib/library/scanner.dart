import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'audio_file.dart';

const unknownArtist = 'Unknown artist';

const folderCoverNames = ['cover.jpg', 'cover.png', 'folder.jpg'];

class KnownFile {
  const KnownFile({required this.mtimeMs, required this.size});

  final int mtimeMs;
  final int size;
}

class ScanRequest {
  const ScanRequest({
    required this.root,
    required this.coversDirectory,
    required this.known,
  });

  final String root;
  final String coversDirectory;
  final Map<String, KnownFile> known;
}

class ScannedTrack {
  const ScannedTrack({
    required this.path,
    required this.mtimeMs,
    required this.size,
    required this.title,
    required this.artist,
    required this.durationMs,
    this.albumArtist,
    this.album,
    this.trackNumber,
    this.discNumber,
    this.coverPath,
  });

  final String path;
  final int mtimeMs;
  final int size;
  final String title;
  final String artist;
  final String? albumArtist;
  final String? album;
  final int? trackNumber;
  final int? discNumber;
  final int durationMs;
  final String? coverPath;
}

class ScanResult {
  const ScanResult({required this.changed, required this.seen});

  final List<ScannedTrack> changed;
  final Set<String> seen;
}

String? _blankToNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<File> findAudioFiles(Directory root) {
  final files = <File>[];
  final pending = <Directory>[root];
  while (pending.isNotEmpty) {
    final directory = pending.removeLast();
    final List<FileSystemEntity> entries;
    try {
      entries = directory.listSync(followLinks: false);
    } on FileSystemException {
      continue;
    }
    for (final entry in entries) {
      if (entry is Directory) {
        pending.add(entry);
      } else if (entry is File && isAudioFile(entry.path)) {
        files.add(entry);
      }
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

String? findFolderCover(String directory, Map<String, String?> cache) {
  if (cache.containsKey(directory)) return cache[directory];
  String? found;
  final List<FileSystemEntity> entries;
  try {
    entries = Directory(directory).listSync(followLinks: false);
  } on FileSystemException {
    cache[directory] = null;
    return null;
  }
  for (final name in folderCoverNames) {
    for (final entry in entries) {
      if (entry is File && fileNameOf(entry.path).toLowerCase() == name) {
        found = entry.path;
        break;
      }
    }
    if (found != null) break;
  }
  cache[directory] = found;
  return found;
}

String fnv1aHex(Uint8List bytes) {
  var hash = 0xcbf29ce484222325;
  for (final byte in bytes) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

String? saveEmbeddedCover(List<Picture> pictures, String coversDirectory) {
  if (pictures.isEmpty) return null;
  final picture = pictures.firstWhere(
    (p) => p.pictureType == PictureType.coverFront,
    orElse: () => pictures.first,
  );
  if (picture.bytes.isEmpty) return null;
  final mime = picture.mimetype.toLowerCase();
  final extension = mime.contains('png') ? 'png' : 'jpg';
  final file = File('$coversDirectory/${fnv1aHex(picture.bytes)}.$extension');
  if (!file.existsSync()) {
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(picture.bytes);
  }
  return file.path;
}

class _Tags {
  const _Tags({
    this.title,
    this.artist,
    this.albumArtist,
    this.album,
    this.trackNumber,
    this.discNumber,
    this.duration,
    this.pictures = const [],
  });

  final String? title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final int? trackNumber;
  final int? discNumber;
  final Duration? duration;
  final List<Picture> pictures;
}

_Tags? _readTags(File file) {
  try {
    if (extensionOf(file.path) == 'mp3') {
      final tag = readAllMetadata(file, getImage: true);
      if (tag is Mp3Metadata) {
        return _Tags(
          title: tag.songName,
          artist: tag.leadPerformer ?? tag.originalArtist,
          albumArtist: tag.bandOrOrchestra,
          album: tag.album,
          trackNumber: tag.trackNumber,
          discNumber: tag.discNumber,
          duration: tag.duration,
          pictures: tag.pictures,
        );
      }
    }
    final meta = readMetadata(file, getImage: true);
    return _Tags(
      title: meta.title,
      artist: meta.artist,
      albumArtist: meta.albumArtist,
      album: meta.album,
      trackNumber: meta.trackNumber,
      discNumber: meta.discNumber,
      duration: meta.duration,
      pictures: meta.pictures,
    );
  } on MetadataParserException {
    return null;
  } on NoMetadataParserException {
    return null;
  } on FileSystemException {
    return null;
  }
}

ScannedTrack readTrack(
  File file,
  FileStat stat,
  String coversDirectory,
  Map<String, String?> folderCovers,
) {
  final tags = _readTags(file);
  String? embedded;
  if (tags != null) {
    try {
      embedded = saveEmbeddedCover(tags.pictures, coversDirectory);
    } on FileSystemException {
      embedded = null;
    }
  }
  final cover =
      embedded ?? findFolderCover(directoryOf(file.path), folderCovers);
  final artist = _blankToNull(tags?.artist) ?? _blankToNull(tags?.albumArtist);
  return ScannedTrack(
    path: file.path,
    mtimeMs: stat.modified.millisecondsSinceEpoch,
    size: stat.size,
    title: _blankToNull(tags?.title) ?? stemOf(file.path),
    artist: artist ?? unknownArtist,
    albumArtist: _blankToNull(tags?.albumArtist),
    album: _blankToNull(tags?.album),
    trackNumber: tags?.trackNumber,
    discNumber: tags?.discNumber,
    durationMs: tags?.duration?.inMilliseconds ?? 0,
    coverPath: cover,
  );
}

ScanResult scanLibrary(ScanRequest request) {
  final root = Directory(request.root);
  final seen = <String>{};
  final changed = <ScannedTrack>[];
  final folderCovers = <String, String?>{};
  for (final file in findAudioFiles(root)) {
    final FileStat stat;
    try {
      stat = file.statSync();
    } on FileSystemException {
      continue;
    }
    seen.add(file.path);
    final known = request.known[file.path];
    final mtimeMs = stat.modified.millisecondsSinceEpoch;
    if (known != null && known.mtimeMs == mtimeMs && known.size == stat.size) {
      continue;
    }
    changed.add(readTrack(file, stat, request.coversDirectory, folderCovers));
  }
  return ScanResult(changed: changed, seen: seen);
}
