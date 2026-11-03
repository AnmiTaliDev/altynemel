import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import '../components/app_shell.dart';
import '../components/layout_mode.dart';
import '../components/mini_player.dart';
import '../components/phone_nav.dart';
import '../components/phone_shell.dart';
import '../components/search_field.dart';
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
import '../settings/catalog.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'about_screen.dart';
import 'advanced_settings_screen.dart';
import 'now_playing_screen.dart';
import 'confirm_dialog.dart';
import 'home_shortcuts.dart';
import 'library_screen.dart';
import 'playlist_screen.dart';
import 'playlists_screen.dart';
import 'queue_screen.dart';
import 'settings_screen.dart';
import 'track_menu.dart';

const String likedContext = 'liked';

const Duration seekStep = Duration(seconds: 5);

enum _SettingsPage { about, freeSoftware, advanced }

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
  bool _railExpanded = false;
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

  void _expandRail() {
    setState(() => _railExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _searchFocus.requestFocus(),
    );
  }

  void _focusSearch() {
    if (sidebarCompactFor(MediaQuery.sizeOf(context).width)) {
      _expandRail();
    } else {
      _searchFocus.requestFocus();
    }
  }

  void _goTo(SidebarDestination value) => setState(() {
    _railExpanded = false;
    _destination = value;
    _playlistId = null;
    _albumId = null;
    _artistId = null;
    _settingsPage = null;
  });

  PhoneTab? _phoneTab() {
    if (_playlistId != null) return PhoneTab.playlists;
    return switch (_destination) {
      SidebarDestination.library || null => PhoneTab.library,
      SidebarDestination.playlists => PhoneTab.playlists,
      SidebarDestination.queue => PhoneTab.queue,
      SidebarDestination.settings => PhoneTab.settings,
      SidebarDestination.nowPlaying => null,
    };
  }

  void _selectPhoneTab(PhoneTab tab) {
    _goTo(switch (tab) {
      PhoneTab.library => SidebarDestination.library,
      PhoneTab.playlists => SidebarDestination.playlists,
      PhoneTab.queue => SidebarDestination.queue,
      PhoneTab.settings => SidebarDestination.settings,
    });
  }

  bool get _canGoBack =>
      _nowPlayingOpen ||
      _railExpanded ||
      _settingsPage != null ||
      _albumId != null ||
      _artistId != null ||
      _playlistId != null;

  void _goBack() {
    setState(() {
      if (_nowPlayingOpen) {
        _nowPlayingOpen = false;
      } else if (_railExpanded) {
        _railExpanded = false;
      } else if (_settingsPage == _SettingsPage.freeSoftware) {
        _settingsPage = _SettingsPage.about;
      } else if (_settingsPage != null) {
        _settingsPage = null;
      } else if (_albumId != null || _artistId != null) {
        _albumId = null;
        _artistId = null;
      } else {
        _playlistId = null;
      }
    });
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
      _destination = isPhone(context)
          ? SidebarDestination.playlists
          : SidebarDestination.library;
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
        onBack: isPhone(context)
            ? () => setState(() => _playlistId = null)
            : null,
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
      case SidebarDestination.playlists:
        return PlaylistsScreen(
          playlists: [
            PlaylistSummary(
              id: likedContext,
              name: Strings.liked,
              trackCount: library.likedTracks.length,
            ),
            for (final p in library.playlists)
              PlaylistSummary(
                id: p.id,
                name: p.name,
                trackCount: library.playlistTracks(p.id).length,
              ),
          ],
          onOpen: (id) => setState(() {
            _playlistId = id;
            _albumId = null;
            _artistId = null;
            _settingsPage = null;
          }),
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
          _SettingsPage.advanced => AdvancedSettingsScreen(
            settings: settings,
            onBack: () => setState(() => _settingsPage = null),
          ),
          _SettingsPage.freeSoftware => FreeSoftwareScreen(
            onBack: () => setState(() => _settingsPage = _SettingsPage.about),
          ),
          null => SettingsScreen(
            settings: settings,
            onChooseFolder: () => _chooseFolder(settings),
            onOpenAbout: () =>
                setState(() => _settingsPage = _SettingsPage.about),
            onOpenAdvanced: () =>
                setState(() => _settingsPage = _SettingsPage.advanced),
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

  Widget _phoneBody(
    LibraryController library,
    PlaybackController playback,
    AppSettings settings,
  ) {
    final body = _body(library, playback, settings);
    final atLibraryRoot =
        (_destination ?? SidebarDestination.library) ==
            SidebarDestination.library &&
        _playlistId == null &&
        _albumId == null &&
        _artistId == null;
    if (!atLibraryRoot) return body;
    final gutter = pageGutter(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, space4, gutter, 0),
          child: SearchField(
            controller: _search,
            focusNode: _searchFocus,
            onChanged: _onSearch,
          ),
        ),
        Expanded(child: body),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = LibraryScope.of(context);
    final playback = PlaybackScope.of(context);
    final settings = AppSettingsScope.of(context);
    final window = WindowScope.maybeOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = sidebarCompactFor(width);
    final phone = isPhoneWidth(width);
    if (!compact) _railExpanded = false;
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
        child: PopScope(
          canPop: !_canGoBack,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _goBack();
          },
          child: Shortcuts(
            shortcuts: homeShortcuts,
            child: Actions(
              actions: {
                PlayPauseIntent: GuardedAction<PlayPauseIntent>(
                  enabled: () => !controlFocused(),
                  run: playback.toggle,
                ),
                PreviousIntent: GuardedAction<PreviousIntent>(
                  enabled: () => !textFieldFocused(),
                  run: playback.previous,
                ),
                NextIntent: GuardedAction<NextIntent>(
                  enabled: () => !textFieldFocused(),
                  run: playback.next,
                ),
                SeekIntent: CallbackAction<SeekIntent>(
                  onInvoke: (intent) {
                    if (controlFocused()) return null;
                    playback.seekBy(
                      Duration(
                        seconds:
                            intent.direction *
                            settings.valueOf(
                              intent.long
                                  ? seekStepLongSeconds
                                  : seekStepSeconds,
                            ),
                      ),
                    );
                    return null;
                  },
                ),
                MuteIntent: GuardedAction<MuteIntent>(
                  enabled: () => !textFieldFocused(),
                  run: playback.toggleMute,
                ),
                CollapseIntent: GuardedAction<CollapseIntent>(
                  enabled: () => _nowPlayingOpen || _railExpanded,
                  run: () => setState(() {
                    _nowPlayingOpen = false;
                    _railExpanded = false;
                  }),
                ),
                FocusSearchIntent: GuardedAction<FocusSearchIntent>(
                  enabled: () => true,
                  run: _focusSearch,
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
                          child: SafeArea(
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
                                        onToggleLike: () => library.setLiked(
                                          current.id,
                                          !liked,
                                        ),
                                        isPlaying: playback.isPlaying,
                                        shuffle: playback.shuffle,
                                        repeat: playback.repeat,
                                        onShuffle: () => playback.setShuffle(
                                          !playback.shuffle,
                                        ),
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
                                          _destination =
                                              SidebarDestination.queue;
                                          _playlistId = null;
                                          _albumId = null;
                                          _artistId = null;
                                          _settingsPage = null;
                                        }),
                                        onCollapse: () => setState(
                                          () => _nowPlayingOpen = false,
                                        ),
                                        onMore: (anchor) =>
                                            _showMenu(current, anchor),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (window == null) return full;
                        return DragToResizeArea(resizeEdgeSize: 6, child: full);
                      }
                      if (phone) {
                        final phoneShell = PhoneShell(
                          titleBar: titleBar,
                          body: _phoneBody(library, playback, settings),
                          miniPlayer: current == null
                              ? null
                              : ValueListenableBuilder<Duration>(
                                  valueListenable: playback.position,
                                  builder: (context, position, _) {
                                    final total =
                                        playback.duration.inMilliseconds;
                                    return MiniPlayer(
                                      title: current.title,
                                      artist: current.artist,
                                      image: coverImage(
                                        current.coverPath,
                                        width: 112,
                                      ),
                                      albumName: current.album,
                                      isPlaying: playback.isPlaying,
                                      progress: total <= 0
                                          ? 0
                                          : position.inMilliseconds / total,
                                      onOpen: () => setState(
                                        () => _nowPlayingOpen = true,
                                      ),
                                      onPlayPause: playback.toggle,
                                    );
                                  },
                                ),
                          nav: PhoneNav(
                            selected: _phoneTab(),
                            onSelected: _selectPhoneTab,
                          ),
                        );
                        if (window == null) return phoneShell;
                        return DragToResizeArea(
                          resizeEdgeSize: 6,
                          child: phoneShell,
                        );
                      }
                      final shell = AppShell(
                        titleBar: titleBar,
                        expanded: _railExpanded,
                        onDismiss: () => setState(() => _railExpanded = false),
                        sidebar: Sidebar(
                          compact: compact && !_railExpanded,
                          onSearch: _expandRail,
                          dragArea: window == null
                              ? null
                              : (child) => DragToMoveArea(child: child),
                          destination: _playlistId == null
                              ? _destination
                              : null,
                          onDestination: _goTo,
                          playlists: playlists,
                          selectedPlaylistId: _playlistId,
                          onPlaylist: (id) => setState(() {
                            _railExpanded = false;
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
                                  current != null &&
                                  library.isLiked(current.id),
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
      ),
    );
  }
}
