import 'package:flutter/material.dart';

import '../components/app_shell.dart';
import '../components/player_bar.dart';
import '../components/sidebar.dart';
import '../library/track.dart';
import '../player/repeat_setting.dart';
import '../screens/playlist_screen.dart';
import 'demo_data.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      sidebar: Sidebar(
        destination: null,
        onDestination: (_) {},
        playlists: demoPlaylists,
        selectedPlaylistId: demoPlaylistId,
        onPlaylist: (_) {},
      ),
      body: PlaylistScreen(
        title: demoPlaylistName,
        tracks: demoTracks,
        currentTrackId: _track.id,
        isPlaying: _playing,
        selectedTrackId: _selected,
        onPlayPause: () => setState(() => _playing = !_playing),
        onSelectTrack: (track) => setState(() => _selected = track.id),
        onPlayTrack: (_) => setState(() {
          _playing = true;
          _position = Duration.zero;
        }),
        onTrackMore: (_) {},
      ),
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
        onPlayPause: () => setState(() => _playing = !_playing),
        onNext: () => setState(() => _position = Duration.zero),
        onRepeat: () => setState(() => _repeat = _nextRepeat()),
        position: _position,
        duration: _track.duration,
        onSeek: (value) => setState(() => _position = value),
        volume: _volume,
        onVolume: (value) => setState(() => _volume = value),
        onQueue: () {},
      ),
    );
  }
}
