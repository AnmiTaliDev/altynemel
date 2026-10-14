class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.album,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final Duration duration;
}
