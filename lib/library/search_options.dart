import '../settings/app_settings.dart';
import '../settings/catalog.dart';

class SearchOptions {
  const SearchOptions({this.album = true, this.artist = true});

  final bool album;
  final bool artist;
}

SearchOptions searchOptionsOf(AppSettings settings) {
  return SearchOptions(
    album: settings.valueOf(searchInAlbum),
    artist: settings.valueOf(searchInArtist),
  );
}
