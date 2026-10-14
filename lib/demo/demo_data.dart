import '../components/sidebar.dart';
import '../library/album.dart';
import '../library/artist.dart';
import '../library/track.dart';

const demoPlaylistId = 'shared-with-me';
const demoPlaylistName = 'Shared with me';

const demoPlaylists = [
  SidebarPlaylist(id: demoPlaylistId, name: demoPlaylistName),
];

const demoTracks = [
  Track(
    id: 'fading-memories',
    title: 'fading memories',
    artist: 'june lu, sløwmind',
    duration: Duration(minutes: 2, seconds: 27),
  ),
];

const demoLibraryTracks = [
  Track(
    id: 'fading-memories',
    title: 'fading memories',
    artist: 'june lu, sløwmind',
    duration: Duration(minutes: 2, seconds: 27),
  ),
  Track(
    id: 'balbyrauyn',
    title: 'Балбырауын',
    artist: 'Құрманғазы',
    album: 'Сарыарқа',
    duration: Duration(minutes: 4, seconds: 12),
  ),
  Track(
    id: 'adai',
    title: 'Адай',
    artist: 'Құрманғазы',
    album: 'Сарыарқа',
    duration: Duration(minutes: 3, seconds: 40),
  ),
  Track(
    id: 'natt',
    title: 'Natt over fjorden',
    artist: 'Bjørk Ødegård',
    album: 'Stille',
    duration: Duration(minutes: 5, seconds: 3),
  ),
];

const demoAlbums = [
  Album(id: 'saryarka', title: 'Сарыарқа', artist: 'Құрманғазы', trackCount: 2),
  Album(id: 'stille', title: 'Stille', artist: 'Bjørk Ødegård', trackCount: 1),
];

const demoArtists = [
  Artist(id: 'kurmangazy', name: 'Құрманғазы', trackCount: 2),
  Artist(id: 'bjork', name: 'Bjørk Ødegård', trackCount: 1),
  Artist(id: 'june-lu', name: 'june lu', trackCount: 1),
  Artist(id: 'slowmind', name: 'sløwmind', trackCount: 1),
];
