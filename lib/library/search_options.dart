import '../settings/app_settings.dart';
import '../settings/catalog.dart';

class SearchOptions {
  const SearchOptions({
    this.title = true,
    this.album = true,
    this.artist = true,
    this.fileName = false,
    this.ignoreAccents = false,
  });

  final bool title;
  final bool album;
  final bool artist;
  final bool fileName;
  final bool ignoreAccents;
}

SearchOptions searchOptionsOf(AppSettings settings) {
  return SearchOptions(
    title: settings.valueOf(searchInTitle),
    album: settings.valueOf(searchInAlbum),
    artist: settings.valueOf(searchInArtist),
    fileName: settings.valueOf(searchInFileName),
    ignoreAccents: settings.valueOf(searchIgnoreAccents),
  );
}
