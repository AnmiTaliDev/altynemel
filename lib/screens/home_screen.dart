import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:window_manager/window_manager.dart';

import '../components/app_shell.dart';
import '../components/window_bar.dart';
import '../integration/window_scope.dart';
import '../components/player_bar.dart';
import '../components/sidebar.dart';
import '../library/cover_image.dart';
import '../library/album_link_scope.dart';
import '../library/artist_link_scope.dart';
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
import '../theme/colors.dart';
import 'about_screen.dart';
import 'now_playing_screen.dart';
import 'confirm_dialog.dart';
import 'library_screen.dart';
import 'playlist_screen.dart';
import 'queue_screen.dart';
import 'settings_screen.dart';
import 'track_menu.dart';

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

class _SeekIntent extends Intent {
  const _SeekIntent(this.seconds);

  final int seconds;
}

class _CollapseIntent extends Intent {
  const _CollapseIntent();
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

enum _SettingsPage { about, freeSoftware }

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
  String? _albumId;
  String? _artistId;
  _SettingsPage? _settingsPage;
  LibraryTab _libraryTab = LibraryTab.albums;
  bool _nowPlayingOpen = false;
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
      if (value.trim().isNotEmpty) {
        _albumId = null;
        _artistId = null;
        _settingsPage = null;
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
    String kind = Strings.playlist,
    ImageProvider? image,
    String? albumName,
    VoidCallback? onBack,
    VoidCallback? onDelete,
    String? menuPlaylistId,
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
      kind: kind,
      image: image,
      albumName: albumName,
      onBack: onBack,
      onDelete: onDelete,
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
      onTrackMore: (track, anchor) =>
          _showMenu(track, anchor, fromPlaylistId: menuPlaylistId),
    );
  }

  Future<void> _showMenu(
    Track track,
    Rect anchor, {
    String? fromPlaylistId,
    int? queuePosition,
  }) {
    return showTrackMenu(
      context,
      track,
      anchor: anchor,
      fromPlaylistId: fromPlaylistId,
      queuePosition: queuePosition,
      onOpenArtist: _openArtist,
      onOpenAlbum: _openAlbum,
      splitArtistNames: AppSettingsScope.of(context).splitArtists,
    );
  }

  void _openArtist(String name) => setState(() {
    _nowPlayingOpen = false;
    _destination = SidebarDestination.library;
    _playlistId = null;
    _albumId = null;
    _settingsPage = null;
    _libraryTab = LibraryTab.artists;
    _artistId = name;
  });

  void _openAlbum(String id) => setState(() {
    _nowPlayingOpen = false;
    _destination = SidebarDestination.library;
    _playlistId = null;
    _artistId = null;
    _settingsPage = null;
    _libraryTab = LibraryTab.albums;
    _albumId = id;
  });

  void _closeDetail() => setState(() {
    _albumId = null;
    _artistId = null;
  });

  Future<void> _deletePlaylist(
    LibraryController library,
    String playlistId,
  ) async {
    final name = _titleOf(library, playlistId);
    final confirmed = await confirmAction(
      context,
      title: Strings.deletePlaylistQuestion(name),
      hint: Strings.deletePlaylistHint,
      confirmLabel: Strings.deletePlaylist,
    );
    if (!confirmed || !mounted) return;
    library.deletePlaylist(playlistId);
    setState(() {
      _playlistId = null;
      _destination = SidebarDestination.library;
    });
  }

  Widget? _detailBody(
    LibraryController library,
    PlaybackController playback,
    AppSettings settings,
  ) {
    final albumId = _albumId;
    if (albumId != null && _playlistId == null) {
      for (final album in library.albums) {
        if (album.id != albumId) continue;
        final tracks = [
          for (final t in library.tracks)
            if (albumKey(t) == albumId) t,
        ];
        return _playlistBody(
          playback,
          album.title,
          tracks,
          kind: Strings.albumKind,
          image: coverImage(album.coverPath, width: 320),
          albumName: album.title,
          onBack: _closeDetail,
        );
      }
    }
    final artistId = _artistId;
    if (artistId != null && _playlistId == null) {
      final tracks = [
        for (final t in library.tracks)
          if (splitArtists(
            t.artist,
            enabled: settings.splitArtists,
          ).contains(artistId))
            t,
      ];
      if (tracks.isNotEmpty) {
        return _playlistBody(
          playback,
          artistId,
          tracks,
          kind: Strings.artistKind,
          onBack: _closeDetail,
        );
      }
    }
    return null;
  }

  Widget _body(
    LibraryController library,
    PlaybackController playback,
    AppSettings settings,
  ) {
    final detail = _detailBody(library, playback, settings);
    if (detail != null) return detail;
    final playlistId = _playlistId;
    if (playlistId != null) {
      final isLiked = playlistId == likedContext;
      return _playlistBody(
        playback,
        _titleOf(library, playlistId),
        _tracksOf(library, playlistId),
        emptyTitle: isLiked ? Strings.likedEmpty : null,
        emptyHint: isLiked ? Strings.likedEmptyHint : null,
        menuPlaylistId: isLiked ? null : playlistId,
        onDelete: isLiked ? null : () => _deletePlaylist(library, playlistId),
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
          initialTab: _libraryTab,
          onTabChanged: (tab) => _libraryTab = tab,
          selectedTrackId: _selected,
          onSelectTrack: _select,
          onPlayTrack: (track) => playback.playTracks(
            tracks,
            tracks.indexWhere((t) => t.id == track.id),
            title: Strings.library,
          ),
          onTrackMore: (track, anchor) => _showMenu(track, anchor),
          onOpenAlbum: (album) => setState(() => _albumId = album.id),
          onOpenArtist: (artist) => setState(() => _artistId = artist.id),
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
          onTrackMore: (track, position, anchor) =>
              _showMenu(track, anchor, queuePosition: position),
          onRemoveTrack: playback.removeFromQueue,
        );
      case SidebarDestination.settings:
        return switch (_settingsPage) {
          _SettingsPage.about => AboutScreen(
            onBack: () => setState(() => _settingsPage = null),
            onOpenFreeSoftware: () =>
                setState(() => _settingsPage = _SettingsPage.freeSoftware),
          ),
          _SettingsPage.freeSoftware => FreeSoftwareScreen(
            onBack: () => setState(() => _settingsPage = _SettingsPage.about),
          ),
          null => SettingsScreen(
            settings: settings,
            onChooseFolder: () => _chooseFolder(settings),
            onOpenAbout: () =>
                setState(() => _settingsPage = _SettingsPage.about),
          ),
        };
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
    final window = WindowScope.maybeOf(context);
    final playlists = [
      const SidebarPlaylist(id: likedContext, name: Strings.liked),
      for (final p in library.playlists)
        SidebarPlaylist(id: p.id, name: p.name),
    ];
    return ArtistLinkScope(
      onOpen: _openArtist,
      split: settings.splitArtists,
      child: AlbumLinkScope(
        onOpen: _openAlbum,
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.space): _PlayPauseIntent(),
            SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
                _PreviousIntent(),
            SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
                _NextIntent(),
            SingleActivator(LogicalKeyboardKey.arrowLeft): _SeekIntent(-5),
            SingleActivator(LogicalKeyboardKey.arrowRight): _SeekIntent(5),
            SingleActivator(LogicalKeyboardKey.escape): _CollapseIntent(),
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
              _SeekIntent: CallbackAction<_SeekIntent>(
                onInvoke: (intent) {
                  if (_controlFocused()) return null;
                  playback.seekBy(Duration(seconds: intent.seconds));
                  return null;
                },
              ),
              _MuteIntent: _GuardedAction<_MuteIntent>(
                enabled: () => !_textFieldFocused(),
                run: playback.toggleMute,
              ),
              _CollapseIntent: _GuardedAction<_CollapseIntent>(
                enabled: () => _nowPlayingOpen,
                run: () => setState(() => _nowPlayingOpen = false),
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
                    final titleBar = window == null
                        ? null
                        : ValueListenableBuilder<bool>(
                            valueListenable: window.maximized,
                            builder: (context, maximized, _) => WindowBar(
                              maximized: maximized,
                              onMinimize: window.minimize,
                              onToggleMaximize: window.toggleMaximize,
                              onClose: window.close,
                            ),
                          );
                    if (_nowPlayingOpen && current != null) {
                      final full = ColoredBox(
                        color: AltynemelColors.of(context).ground,
                        child: Column(
                          children: [
                            ?titleBar,
                            Expanded(
                              child: ValueListenableBuilder<Duration>(
                                valueListenable: playback.position,
                                builder: (context, position, _) {
                                  final liked = library.isLiked(current.id);
                                  return NowPlayingScreen(
                                    title: current.title,
                                    artist: current.artist,
                                    album: current.album,
                                    albumId: current.album == null
                                        ? null
                                        : albumKey(current),
                                    image: coverImage(
                                      current.coverPath,
                                      width: 640,
                                    ),
                                    liked: liked,
                                    onToggleLike: () =>
                                        library.setLiked(current.id, !liked),
                                    isPlaying: playback.isPlaying,
                                    shuffle: playback.shuffle,
                                    repeat: playback.repeat,
                                    onShuffle: () =>
                                        playback.setShuffle(!playback.shuffle),
                                    onPrevious: playback.previous,
                                    onPlayPause: playback.toggle,
                                    onNext: playback.next,
                                    onRepeat: () => playback.setRepeat(
                                      _nextRepeat(playback.repeat),
                                    ),
                                    position: position,
                                    duration: playback.duration,
                                    onSeek: playback.seek,
                                    volume: playback.volume,
                                    volumeStep: settings.volumeStep,
                                    onVolume: playback.setVolume,
                                    onQueue: () => setState(() {
                                      _nowPlayingOpen = false;
                                      _destination = SidebarDestination.queue;
                                      _playlistId = null;
                                      _albumId = null;
                                      _artistId = null;
                                      _settingsPage = null;
                                    }),
                                    onCollapse: () =>
                                        setState(() => _nowPlayingOpen = false),
                                    onMore: (anchor) =>
                                        _showMenu(current, anchor),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                      if (window == null) return full;
                      return DragToResizeArea(resizeEdgeSize: 6, child: full);
                    }
                    final shell = AppShell(
                      titleBar: titleBar,
                      sidebar: Sidebar(
                        dragArea: window == null
                            ? null
                            : (child) => DragToMoveArea(child: child),
                        destination: _playlistId == null ? _destination : null,
                        onDestination: (value) => setState(() {
                          _destination = value;
                          _playlistId = null;
                          _albumId = null;
                          _artistId = null;
                          _settingsPage = null;
                        }),
                        playlists: playlists,
                        selectedPlaylistId: _playlistId,
                        onPlaylist: (id) => setState(() {
                          _playlistId = id;
                          _albumId = null;
                          _artistId = null;
                          _settingsPage = null;
                        }),
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
                            liked:
                                current != null && library.isLiked(current.id),
                            onToggleLike: current == null
                                ? null
                                : () => library.setLiked(
                                    current.id,
                                    !library.isLiked(current.id),
                                  ),
                            isPlaying: playback.isPlaying,
                            shuffle: playback.shuffle,
                            repeat: playback.repeat,
                            onShuffle: () =>
                                playback.setShuffle(!playback.shuffle),
                            onPrevious: current == null
                                ? null
                                : playback.previous,
                            onPlayPause: current == null
                                ? null
                                : playback.toggle,
                            onNext: current == null ? null : playback.next,
                            onRepeat: () => playback.setRepeat(
                              _nextRepeat(playback.repeat),
                            ),
                            position: position,
                            duration: playback.duration,
                            onSeek: current == null ? null : playback.seek,
                            volume: playback.volume,
                            volumeStep: settings.volumeStep,
                            onVolume: playback.setVolume,
                            onOpenNowPlaying: () =>
                                setState(() => _nowPlayingOpen = true),
                            onQueue: () => setState(() {
                              _destination = SidebarDestination.queue;
                              _playlistId = null;
                              _albumId = null;
                              _artistId = null;
                              _settingsPage = null;
                            }),
                          );
                        },
                      ),
                    );
                    if (window == null) return shell;
                    return DragToResizeArea(resizeEdgeSize: 6, child: shell);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
