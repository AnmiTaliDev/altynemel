class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.album,
    this.albumArtist,
    this.trackNumber,
    this.discNumber,
    this.coverPath,
    this.path,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtist;
  final int? trackNumber;
  final int? discNumber;
  final Duration duration;
  final String? coverPath;
  final String? path;
}
