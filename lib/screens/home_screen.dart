import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../components/app_shell.dart';
import '../components/player_bar.dart';
import '../components/sidebar.dart';
import '../library/cover_image.dart';
import '../library/grouping.dart';
import '../library/library_controller.dart';
import '../library/library_scope.dart';
import '../library/track.dart';
import '../player/repeat_setting.dart';
import '../settings/app_settings.dart';
import '../settings/app_settings_scope.dart';
import '../strings.dart';
import 'library_screen.dart';
import 'playlist_screen.dart';
import 'queue_screen.dart';
import 'settings_screen.dart';

const String likedContext = 'liked';
const String libraryContext = 'library';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialDestination});

  final SidebarDestination? initialDestination;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();
  late SidebarDestination? _destination =
      widget.initialDestination ?? SidebarDestination.library;
  String? _playlistId;
  String _query = '';
  Track? _current;
  String _context = libraryContext;
  bool _playing = false;
  bool _shuffle = false;
  RepeatSetting _repeat = RepeatSetting.off;
  Duration _position = Duration.zero;
  int _volume = 70;
  String? _selected;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Track> _tracksOf(LibraryController library, String context) {
    if (context == libraryContext) return library.tracks;
    if (context == likedContext) return library.likedTracks;
    return library.playlistTracks(context);
  }

  String _titleOf(LibraryController library, String context) {
    if (context == libraryContext) return Strings.library;
    if (context == likedContext) return Strings.liked;
    for (final playlist in library.playlists) {
      if (playlist.id == context) return playlist.name;
    }
    return Strings.playlist;
  }

  void _select(Track track) => setState(() => _selected = track.id);

  void _play(Track track, String context) {
    setState(() {
      _current = track;
      _context = context;
      _playing = true;
      _position = Duration.zero;
    });
  }

  void _togglePlay() {
    if (_current == null) return;
    setState(() => _playing = !_playing);
  }

  void _step(LibraryController library, int delta) {
    final current = _current;
    if (current == null) return;
    final list = _tracksOf(library, _context);
    final index = list.indexWhere((t) => t.id == current.id);
    if (index < 0 || list.isEmpty) return;
    final next = list[(index + delta) % list.length];
    _play(next, _context);
  }

  RepeatSetting _nextRepeat() {
    return switch (_repeat) {
      RepeatSetting.off => RepeatSetting.all,
      RepeatSetting.all => RepeatSetting.one,
      RepeatSetting.one => RepeatSetting.off,
    };
  }

  Future<void> _chooseFolder(AppSettings settings) async {
    final path = await getDirectoryPath(
      initialDirectory: settings.libraryFolder,
    );
    if (path != null) settings.setLibraryFolder(path);
  }

  void _dropped(DropDoneDetails details, AppSettings settings) {
    for (final item in details.files) {
      if (FileSystemEntity.isDirectorySync(item.path)) {
        settings.setLibraryFolder(item.path);
        return;
      }
    }
  }

  void _onSearch(String value) {
    setState(() {
      _query = value;
      if (value.trim().isNotEmpty &&
          _destination != SidebarDestination.library) {
        _destination = SidebarDestination.library;
        _playlistId = null;
      }
    });
  }

  Widget _playlistBody(LibraryController library, String id) {
    final tracks = _tracksOf(library, id);
    final isLiked = id == likedContext;
    final playingHere =
        _current != null && tracks.any((t) => t.id == _current!.id);
    return PlaylistScreen(
      title: _titleOf(library, id),
      tracks: tracks,
      currentTrackId: _current?.id,
      isPlaying: _playing,
      selectedTrackId: _selected,
      emptyTitle: isLiked ? Strings.likedEmpty : null,
      emptyHint: isLiked ? Strings.likedEmptyHint : null,
      onPlayPause: () {
        if (playingHere) {
          _togglePlay();
        } else if (tracks.isNotEmpty) {
          _play(tracks.first, id);
        }
      },
      onSelectTrack: _select,
      onPlayTrack: (track) => _play(track, id),
      onTrackMore: (_) {},
    );
  }

  Widget _body(LibraryController library, AppSettings settings) {
    if (_playlistId != null) return _playlistBody(library, _playlistId!);
    switch (_destination) {
      case SidebarDestination.library:
      case null:
        return LibraryScreen(
          albums: filterAlbums(library.albums, _query),
          artists: filterArtists(library.artists, _query),
          tracks: filterTracks(library.tracks, _query),
          libraryEmpty: library.tracks.isEmpty,
          scanning: library.scanning,
          error: library.error,
          currentTrackId: _current?.id,
          isPlaying: _playing,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: (track) => _play(track, libraryContext),
          onTrackMore: (_) {},
          onOpenAlbum: (_) {},
          onOpenArtist: (_) {},
          onOpenSettings: () =>
              setState(() => _destination = SidebarDestination.settings),
        );
      case SidebarDestination.queue:
        final tracks = _current == null
            ? const <Track>[]
            : _tracksOf(library, _context);
        final index = _current == null
            ? null
            : tracks.indexWhere((t) => t.id == _current!.id);
        return QueueScreen(
          tracks: tracks,
          currentIndex: (index == null || index < 0) ? null : index,
          isPlaying: _playing,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: (track) => _play(track, _context),
          onTrackMore: (_) {},
        );
      case SidebarDestination.settings:
        return SettingsScreen(
          settings: settings,
          onChooseFolder: () => _chooseFolder(settings),
        );
      case SidebarDestination.nowPlaying:
        return _playlistBody(library, _context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = LibraryScope.of(context);
    final settings = AppSettingsScope.of(context);
    final current = _current;
    final playlists = [
      const SidebarPlaylist(id: likedContext, name: Strings.liked),
      for (final p in library.playlists)
        SidebarPlaylist(id: p.id, name: p.name),
    ];
    return DropTarget(
      onDragDone: (details) => _dropped(details, settings),
      child: AppShell(
        sidebar: Sidebar(
          destination: _playlistId == null ? _destination : null,
          onDestination: (value) => setState(() {
            _destination = value;
            _playlistId = null;
          }),
          playlists: playlists,
          selectedPlaylistId: _playlistId,
          onPlaylist: (id) => setState(() => _playlistId = id),
          searchController: _search,
          onSearchChanged: _onSearch,
        ),
        body: _body(library, settings),
        playerBar: PlayerBar(
          title: current?.title,
          artist: current?.artist,
          image: coverImage(current?.coverPath, width: 112),
          albumName: current?.album,
          liked: current != null && library.isLiked(current.id),
          onToggleLike: current == null
              ? null
              : () =>
                    library.setLiked(current.id, !library.isLiked(current.id)),
          isPlaying: _playing,
          shuffle: _shuffle,
          repeat: _repeat,
          onShuffle: () => setState(() => _shuffle = !_shuffle),
          onPrevious: current == null ? null : () => _step(library, -1),
          onPlayPause: current == null ? null : _togglePlay,
          onNext: current == null ? null : () => _step(library, 1),
          onRepeat: () => setState(() => _repeat = _nextRepeat()),
          position: _position,
          duration: current?.duration ?? Duration.zero,
          onSeek: current == null
              ? null
              : (value) => setState(() => _position = value),
          volume: _volume,
          onVolume: (value) => setState(() => _volume = value),
          onQueue: () => setState(() {
            _destination = SidebarDestination.queue;
            _playlistId = null;
          }),
        ),
      ),
    );
  }
}
