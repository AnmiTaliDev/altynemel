import 'package:flutter/material.dart';

import '../components/app_shell.dart';
import '../components/player_bar.dart';
import '../components/sidebar.dart';
import '../library/track.dart';
import '../player/repeat_setting.dart';
import '../screens/library_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/queue_screen.dart';
import '../screens/settings_screen.dart';
import '../settings/app_settings_scope.dart';
import 'demo_data.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key, this.initialDestination});

  final SidebarDestination? initialDestination;

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late SidebarDestination? _destination = widget.initialDestination;
  bool _playing = true;
  bool _liked = false;
  bool _shuffle = false;
  RepeatSetting _repeat = RepeatSetting.off;
  Duration _position = const Duration(seconds: 48);
  int _volume = 70;
  String? _selected;

  Track get _track => demoTracks.first;

  RepeatSetting _nextRepeat() {
    return switch (_repeat) {
      RepeatSetting.off => RepeatSetting.all,
      RepeatSetting.all => RepeatSetting.one,
      RepeatSetting.one => RepeatSetting.off,
    };
  }

  void _select(Track track) => setState(() => _selected = track.id);

  void _play(Track track) {
    setState(() {
      _playing = true;
      _position = Duration.zero;
    });
  }

  void _togglePlay() => setState(() => _playing = !_playing);

  Widget _body() {
    switch (_destination) {
      case SidebarDestination.library:
        return LibraryScreen(
          albums: demoAlbums,
          artists: demoArtists,
          tracks: demoLibraryTracks,
          currentTrackId: _track.id,
          isPlaying: _playing,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: _play,
          onTrackMore: (_) {},
          onOpenAlbum: (_) {},
          onOpenArtist: (_) {},
          onOpenSettings: () =>
              setState(() => _destination = SidebarDestination.settings),
        );
      case SidebarDestination.queue:
        return QueueScreen(
          tracks: demoLibraryTracks,
          currentIndex: 0,
          isPlaying: _playing,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: _play,
          onTrackMore: (_) {},
        );
      case SidebarDestination.settings:
        return SettingsScreen(settings: AppSettingsScope.of(context));
      case SidebarDestination.nowPlaying:
      case null:
        return PlaylistScreen(
          title: demoPlaylistName,
          tracks: demoTracks,
          currentTrackId: _track.id,
          isPlaying: _playing,
          selectedTrackId: _selected,
          onPlayPause: _togglePlay,
          onSelectTrack: _select,
          onPlayTrack: _play,
          onTrackMore: (_) {},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      sidebar: Sidebar(
        destination: _destination,
        onDestination: (value) => setState(() => _destination = value),
        playlists: demoPlaylists,
        selectedPlaylistId: _destination == null ? demoPlaylistId : null,
        onPlaylist: (_) => setState(() => _destination = null),
      ),
      body: _body(),
      playerBar: PlayerBar(
        title: _track.title,
        artist: _track.artist,
        liked: _liked,
        onToggleLike: () => setState(() => _liked = !_liked),
        isPlaying: _playing,
        shuffle: _shuffle,
        repeat: _repeat,
        onShuffle: () => setState(() => _shuffle = !_shuffle),
        onPrevious: () => setState(() => _position = Duration.zero),
        onPlayPause: _togglePlay,
        onNext: () => setState(() => _position = Duration.zero),
        onRepeat: () => setState(() => _repeat = _nextRepeat()),
        position: _position,
        duration: _track.duration,
        onSeek: (value) => setState(() => _position = value),
        volume: _volume,
        onVolume: (value) => setState(() => _volume = value),
        onQueue: () => setState(() => _destination = SidebarDestination.queue),
      ),
    );
  }
}
