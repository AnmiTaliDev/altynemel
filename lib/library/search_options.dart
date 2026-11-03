import '../settings/app_settings.dart';
import '../settings/catalog.dart';

class SearchOptions {
  const SearchOptions({this.album = true});

  final bool album;
}

SearchOptions searchOptionsOf(AppSettings settings) {
  return SearchOptions(album: settings.valueOf(searchInAlbum));
}
