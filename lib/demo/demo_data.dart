import '../components/sidebar.dart';
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
