class Strings {
  static const appName = 'Altynemel';
  static const play = 'Play';
  static const pause = 'Pause';
  static const previousTrack = 'Previous track';
  static const nextTrack = 'Next track';
  static const shuffle = 'Shuffle';
  static const repeat = 'Repeat';
  static const repeatAll = 'Repeat all';
  static const repeatOne = 'Repeat one';
  static const addToFavorites = 'Add to favorites';
  static const removeFromFavorites = 'Remove from favorites';
  static const search = 'Search';
  static const playlists = 'Playlists';
  static const playlist = 'Playlist';
  static const nowPlaying = 'Now playing';
  static const library = 'Library';
  static const queue = 'Queue';
  static const volume = 'Volume';
  static const seek = 'Seek';
  static const coverUnavailable = 'Cover art unavailable';
  static const unavailableOffline = 'Unavailable offline';
  static const downloaded = 'Downloaded';
  static const playingNow = 'Playing now';
  static const mainNavigation = 'Main navigation';
  static const player = 'Player';
  static const columnNumber = '#';
  static const columnTitle = 'Title';
  static const columnAlbum = 'Album';
  static const columnTime = 'Time';

  static String coverOf(String album) => 'Cover art: $album';
  static String moreAbout(String title) => 'More about $title';
  static String nowPlayingCard(String title, String artist) =>
      'Now playing: $title, $artist';
  static String songsIn(String playlist) => 'Songs in $playlist';
  static String percent(int value) => '$value percent';
  static String songCount(int count) => count == 1 ? '1 song' : '$count songs';
}
