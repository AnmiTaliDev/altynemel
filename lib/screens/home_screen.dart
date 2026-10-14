import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/app_shell.dart';
import '../components/player_bar.dart';
import '../components/sidebar.dart';
import '../library/cover_image.dart';
import '../library/grouping.dart';
import '../library/library_controller.dart';
import '../library/library_scope.dart';
import '../library/track.dart';
import '../player/playback_controller.dart';
import '../player/playback_scope.dart';
import '../player/repeat_setting.dart';
import '../settings/app_settings.dart';
import '../settings/app_settings_scope.dart';
import '../strings.dart';
import 'library_screen.dart';
import 'playlist_screen.dart';
import 'queue_screen.dart';
import 'settings_screen.dart';

const String likedContext = 'liked';

const Duration seekStep = Duration(seconds: 5);

class _PlayPauseIntent extends Intent {
  const _PlayPauseIntent();
}

class _PreviousIntent extends Intent {
  const _PreviousIntent();
}

class _NextIntent extends Intent {
  const _NextIntent();
}

class _MuteIntent extends Intent {
  const _MuteIntent();
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _GuardedAction<T extends Intent> extends Action<T> {
  _GuardedAction({required this.enabled, required this.run});

  final bool Function() enabled;
  final void Function() run;

  @override
  bool isEnabled(T intent) => enabled();

  @override
  Object? invoke(T intent) {
    run();
    return null;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialDestination});

  final SidebarDestination? initialDestination;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late SidebarDestination? _destination =
      widget.initialDestination ?? SidebarDestination.library;
  String? _playlistId;
  String _query = '';
  String? _selected;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Track> _tracksOf(LibraryController library, String id) {
    if (id == likedContext) return library.likedTracks;
    return library.playlistTracks(id);
  }

  String _titleOf(LibraryController library, String id) {
    if (id == likedContext) return Strings.liked;
    for (final playlist in library.playlists) {
      if (playlist.id == id) return playlist.name;
    }
    return Strings.playlist;
  }

  void _select(Track track) => setState(() => _selected = track.id);

  RepeatSetting _nextRepeat(RepeatSetting value) {
    return switch (value) {
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

  bool _textFieldFocused() {
    final context = FocusManager.instance.primaryFocus?.context;
    return context != null &&
        context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _controlFocused() {
    final context = FocusManager.instance.primaryFocus?.context;
    return context != null &&
        (context.findAncestorWidgetOfExactType<EditableText>() != null ||
            context.findAncestorWidgetOfExactType<FocusableActionDetector>() !=
                null);
  }

  Widget _playlistBody(
    PlaybackController playback,
    String title,
    List<Track> tracks, {
    String? emptyTitle,
    String? emptyHint,
  }) {
    final current = playback.current;
    final playingHere =
        current != null && tracks.any((t) => t.id == current.id);
    return PlaylistScreen(
      title: title,
      tracks: tracks,
      currentTrackId: current?.id,
      isPlaying: playback.isPlaying,
      selectedTrackId: _selected,
      emptyTitle: emptyTitle,
      emptyHint: emptyHint,
      onPlayPause: () {
        if (playingHere) {
          playback.toggle();
        } else if (tracks.isNotEmpty) {
          playback.playTracks(tracks, 0, title: title);
        }
      },
      onSelectTrack: _select,
      onPlayTrack: (track) => playback.playTracks(
        tracks,
        tracks.indexWhere((t) => t.id == track.id),
        title: title,
      ),
      onTrackMore: (_) {},
    );
  }

  Widget _body(
    LibraryController library,
    PlaybackController playback,
    AppSettings settings,
  ) {
    final playlistId = _playlistId;
    if (playlistId != null) {
      final isLiked = playlistId == likedContext;
      return _playlistBody(
        playback,
        _titleOf(library, playlistId),
        _tracksOf(library, playlistId),
        emptyTitle: isLiked ? Strings.likedEmpty : null,
        emptyHint: isLiked ? Strings.likedEmptyHint : null,
      );
    }
    switch (_destination) {
      case SidebarDestination.library:
      case null:
        final tracks = filterTracks(library.tracks, _query);
        return LibraryScreen(
          albums: filterAlbums(library.albums, _query),
          artists: filterArtists(library.artists, _query),
          tracks: tracks,
          libraryEmpty: library.tracks.isEmpty,
          scanning: library.scanning,
          error: library.error,
          currentTrackId: playback.current?.id,
          isPlaying: playback.isPlaying,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: (track) => playback.playTracks(
            tracks,
            tracks.indexWhere((t) => t.id == track.id),
            title: Strings.library,
          ),
          onTrackMore: (_) {},
          onOpenAlbum: (_) {},
          onOpenArtist: (_) {},
          onOpenSettings: () =>
              setState(() => _destination = SidebarDestination.settings),
        );
      case SidebarDestination.queue:
        final position = playback.queuePosition;
        return QueueScreen(
          tracks: playback.queueTracks,
          currentIndex: position < 0 ? null : position,
          isPlaying: playback.isPlaying,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: (track) {
            final index = playback.queueTracks.indexWhere(
              (t) => t.id == track.id,
            );
            playback.jumpTo(index);
          },
          onTrackMore: (_) {},
        );
      case SidebarDestination.settings:
        return SettingsScreen(
          settings: settings,
          onChooseFolder: () => _chooseFolder(settings),
        );
      case SidebarDestination.nowPlaying:
        return _playlistBody(
          playback,
          playback.sourceTitle.isEmpty
              ? Strings.nowPlaying
              : playback.sourceTitle,
          playback.sourceTracks,
          emptyTitle: Strings.nothingPlaying,
          emptyHint: Strings.nothingPlayingHint,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = LibraryScope.of(context);
    final playback = PlaybackScope.of(context);
    final settings = AppSettingsScope.of(context);
    final playlists = [
      const SidebarPlaylist(id: likedContext, name: Strings.liked),
      for (final p in library.playlists)
        SidebarPlaylist(id: p.id, name: p.name),
    ];
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): _PlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            _PreviousIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            _NextIntent(),
        SingleActivator(LogicalKeyboardKey.keyM): _MuteIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _FocusSearchIntent(),
      },
      child: Actions(
        actions: {
          _PlayPauseIntent: _GuardedAction<_PlayPauseIntent>(
            enabled: () => !_controlFocused(),
            run: playback.toggle,
          ),
          _PreviousIntent: _GuardedAction<_PreviousIntent>(
            enabled: () => !_textFieldFocused(),
            run: playback.previous,
          ),
          _NextIntent: _GuardedAction<_NextIntent>(
            enabled: () => !_textFieldFocused(),
            run: playback.next,
          ),
          _MuteIntent: _GuardedAction<_MuteIntent>(
            enabled: () => !_textFieldFocused(),
            run: playback.toggleMute,
          ),
          _FocusSearchIntent: _GuardedAction<_FocusSearchIntent>(
            enabled: () => true,
            run: _searchFocus.requestFocus,
          ),
        },
        child: Focus(
          autofocus: true,
          child: DropTarget(
            onDragDone: (details) => _dropped(details, settings),
            child: ListenableBuilder(
              listenable: Listenable.merge([library, playback]),
              builder: (context, _) {
                final current = playback.current;
                return AppShell(
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
                    searchFocusNode: _searchFocus,
                    onSearchChanged: _onSearch,
                  ),
                  body: _body(library, playback, settings),
                  playerBar: ValueListenableBuilder<Duration>(
                    valueListenable: playback.position,
                    builder: (context, position, _) {
                      return PlayerBar(
                        title: current?.title,
                        artist: current?.artist,
                        image: coverImage(current?.coverPath, width: 112),
                        albumName: current?.album,
                        liked: current != null && library.isLiked(current.id),
                        onToggleLike: current == null
                            ? null
                            : () => library.setLiked(
                                current.id,
                                !library.isLiked(current.id),
                              ),
                        isPlaying: playback.isPlaying,
                        shuffle: playback.shuffle,
                        repeat: playback.repeat,
                        onShuffle: () => playback.setShuffle(!playback.shuffle),
                        onPrevious: current == null ? null : playback.previous,
                        onPlayPause: current == null ? null : playback.toggle,
                        onNext: current == null ? null : playback.next,
                        onRepeat: () =>
                            playback.setRepeat(_nextRepeat(playback.repeat)),
                        position: position,
                        duration: playback.duration,
                        onSeek: current == null ? null : playback.seek,
                        volume: playback.volume,
                        volumeStep: settings.volumeStep,
                        onVolume: playback.setVolume,
                        onQueue: () => setState(() {
                          _destination = SidebarDestination.queue;
                          _playlistId = null;
                        }),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
