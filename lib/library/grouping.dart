import '../settings/app_settings.dart';
import '../settings/choices.dart';
import 'album.dart';
import 'artist.dart';
import 'audio_file.dart';
import 'search_options.dart';
import 'text_fold.dart';
import 'track.dart';

const unknownAlbum = 'Unknown album';

const defaultArtistSeparators = ', | ; | feat. | ft. | featuring';

final _separatorPatterns = <String, RegExp>{};

RegExp artistSeparatorPattern(String spec) {
  return _separatorPatterns.putIfAbsent(spec, () {
    final symbols = <String>[];
    final words = <String>[];
    for (final raw in spec.split('|')) {
      final token = raw.trim();
      if (token.isEmpty) continue;
      if (RegExp(r'[A-Za-z]').hasMatch(token)) {
        final dotted = token.endsWith('.');
        final body = dotted ? token.substring(0, token.length - 1) : token;
        words.add('${RegExp.escape(body)}${dotted ? r'\.?' : ''}');
      } else {
        symbols.add(RegExp.escape(token));
      }
    }
    final alternatives = [
      ...symbols,
      if (words.isNotEmpty) r'\s(?:' + words.join('|') + r')\s',
    ];
    if (alternatives.isEmpty) return RegExp(r'(?!)');
    return RegExp(
      r'\s*(?:' + alternatives.join('|') + r')\s*',
      caseSensitive: false,
    );
  });
}

List<String> splitArtists(
  String value, {
  required bool enabled,
  String separators = defaultArtistSeparators,
}) {
  if (!enabled) return [value.trim()];
  final parts = value
      .split(artistSeparatorPattern(separators))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  return parts.isEmpty ? [value.trim()] : parts;
}

const variousArtists = 'Various artists';

int _compareText(String a, String b) =>
    a.toLowerCase().compareTo(b.toLowerCase());

String albumKey(Track track) {
  final owner =
      track.albumArtist ??
      (track.album != null ? directoryOf(track.path ?? '') : track.artist);
  return '$owner\u0000${track.album ?? unknownAlbum}';
}

Map<String, List<Track>> _groupAlbums(List<Track> tracks) {
  final groups = <String, List<Track>>{};
  for (final track in tracks) {
    groups.putIfAbsent(albumKey(track), () => []).add(track);
  }
  return groups;
}

String _albumArtist(List<Track> tracks) {
  final first = tracks.first;
  if (first.albumArtist != null) return first.albumArtist!;
  final artists = tracks.map((t) => t.artist).toSet();
  return artists.length == 1 ? artists.first : variousArtists;
}

int _compareGroups(List<Track> a, List<Track> b) {
  final title = _compareText(
    a.first.album ?? unknownAlbum,
    b.first.album ?? unknownAlbum,
  );
  return title != 0 ? title : _compareText(_albumArtist(a), _albumArtist(b));
}

List<Track> orderAlbumTracks(List<Track> tracks, AlbumOrder order) {
  final sorted = [...tracks];
  switch (order) {
    case AlbumOrder.discAndTrack:
      sorted.sort((a, b) {
        final disc = (a.discNumber ?? 1).compareTo(b.discNumber ?? 1);
        if (disc != 0) return disc;
        final number = (a.trackNumber ?? 1 << 30).compareTo(
          b.trackNumber ?? 1 << 30,
        );
        if (number != 0) return number;
        return _compareText(
          fileNameOf(a.path ?? a.title),
          fileNameOf(b.path ?? b.title),
        );
      });
    case AlbumOrder.fileName:
      sorted.sort(
        (a, b) => _compareText(
          fileNameOf(a.path ?? a.title),
          fileNameOf(b.path ?? b.title),
        ),
      );
  }
  return sorted;
}

List<Track> sortLibraryTracks(List<Track> tracks, AlbumOrder order) {
  final groups = _groupAlbums(tracks).values.toList()..sort(_compareGroups);
  return [for (final group in groups) ...orderAlbumTracks(group, order)];
}

List<Album> buildAlbums(
  List<Track> tracks, {
  AlbumSort sort = AlbumSort.title,
}) {
  final groups = _groupAlbums(tracks).entries.toList()
    ..sort((a, b) {
      switch (sort) {
        case AlbumSort.title:
          break;
        case AlbumSort.artist:
          final byArtist = _compareText(
            _albumArtist(a.value),
            _albumArtist(b.value),
          );
          if (byArtist != 0) return byArtist;
        case AlbumSort.trackCount:
          final byCount = b.value.length.compareTo(a.value.length);
          if (byCount != 0) return byCount;
      }
      return _compareGroups(a.value, b.value);
    });
  return [
    for (final entry in groups)
      Album(
        id: entry.key,
        title: entry.value.first.album ?? unknownAlbum,
        artist: _albumArtist(entry.value),
        trackCount: entry.value.length,
        coverPath: entry.value
            .map((t) => t.coverPath)
            .firstWhere((c) => c != null, orElse: () => null),
      ),
  ];
}

List<Artist> buildArtists(
  List<Track> tracks, {
  required bool split,
  String separators = defaultArtistSeparators,
  ArtistSort sort = ArtistSort.name,
}) {
  final counts = <String, int>{};
  for (final track in tracks) {
    for (final name in splitArtists(
      track.artist,
      enabled: split,
      separators: separators,
    ).toSet()) {
      counts[name] = (counts[name] ?? 0) + 1;
    }
  }
  final artists = [
    for (final entry in counts.entries)
      Artist(id: entry.key, name: entry.key, trackCount: entry.value),
  ];
  artists.sort((a, b) {
    if (sort == ArtistSort.trackCount) {
      final byCount = b.trackCount.compareTo(a.trackCount);
      if (byCount != 0) return byCount;
    }
    return _compareText(a.name, b.name);
  });
  return artists;
}

String _prepare(String value, SearchOptions options) =>
    options.ignoreAccents ? foldAccents(value) : value.toLowerCase();

bool _matches(String? value, String query, SearchOptions options) {
  return value != null && _prepare(value, options).contains(query);
}

List<Track> filterTracks(
  List<Track> tracks,
  String query, [
  SearchOptions options = const SearchOptions(),
]) {
  final q = _prepare(query.trim(), options);
  if (q.isEmpty) return tracks;
  return [
    for (final t in tracks)
      if ((options.title && _matches(t.title, q, options)) ||
          (options.artist && _matches(t.artist, q, options)) ||
          (options.album && _matches(t.album, q, options)) ||
          (options.fileName && _matches(fileNameOf(t.path ?? ''), q, options)))
        t,
  ];
}

List<Album> filterAlbums(
  List<Album> albums,
  String query, [
  SearchOptions options = const SearchOptions(),
]) {
  final q = _prepare(query.trim(), options);
  if (q.isEmpty) return albums;
  return [
    for (final a in albums)
      if (_matches(a.title, q, options) || _matches(a.artist, q, options)) a,
  ];
}

List<Artist> filterArtists(
  List<Artist> artists,
  String query, [
  SearchOptions options = const SearchOptions(),
]) {
  final q = _prepare(query.trim(), options);
  if (q.isEmpty) return artists;
  return [
    for (final a in artists)
      if (_matches(a.name, q, options)) a,
  ];
}
