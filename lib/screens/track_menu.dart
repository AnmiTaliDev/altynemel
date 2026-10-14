import 'dart:io';

import 'package:flutter/material.dart';

import '../components/menu.dart';
import '../components/icon_data.dart';
import '../library/library_controller.dart';
import '../library/library_scope.dart';
import '../library/track.dart';
import '../player/playback_controller.dart';
import '../player/playback_scope.dart';
import '../strings.dart';

Future<void> showTrackMenu(
  BuildContext context,
  Track track, {
  String? fromPlaylistId,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: Strings.closeMenu,
    barrierColor: const Color(0x66000000),
    transitionDuration: Duration.zero,
    pageBuilder: (dialogContext, _, _) => Material(
      type: MaterialType.transparency,
      child: Center(
        child: _TrackMenu(
          track: track,
          fromPlaylistId: fromPlaylistId,
          library: LibraryScope.of(context),
          playback: PlaybackScope.of(context),
        ),
      ),
    ),
  );
}

enum _Page { actions, playlists, create }

class _TrackMenu extends StatefulWidget {
  const _TrackMenu({
    required this.track,
    required this.library,
    required this.playback,
    this.fromPlaylistId,
  });

  final String? fromPlaylistId;
  final Track track;
  final LibraryController library;
  final PlaybackController playback;

  @override
  State<_TrackMenu> createState() => _TrackMenuState();
}

class _TrackMenuState extends State<_TrackMenu> {
  final TextEditingController _name = TextEditingController();
  _Page _page = _Page.actions;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  void _run(VoidCallback action) {
    action();
    _close();
  }

  Future<void> _showInFolder() async {
    final path = widget.track.path;
    if (path == null) return;
    final directory = File(path).parent.path;
    final command = Platform.isMacOS ? 'open' : 'xdg-open';
    try {
      await Process.start(command, [directory]);
    } on ProcessException {
      return;
    }
  }

  void _create(String value) {
    final name = value.trim();
    if (name.isEmpty) return;
    final id = widget.library.createPlaylist(name);
    widget.library.addToPlaylist(id, widget.track.id);
    _close();
  }

  bool get _canShowFolder =>
      widget.track.path != null && (Platform.isLinux || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    final library = widget.library;
    final playback = widget.playback;
    final liked = library.isLiked(track.id);
    switch (_page) {
      case _Page.actions:
        return MenuPanel(
          semanticLabel: Strings.menuFor(track.title),
          title: track.title,
          children: [
            MenuItem(
              label: Strings.play,
              icon: IconId.play,
              autofocus: true,
              onPressed: () => _run(
                () => playback.playTracks([track], 0, title: track.title),
              ),
            ),
            MenuItem(
              label: Strings.playNext,
              icon: IconId.next,
              onPressed: () => _run(() => playback.playNext(track)),
            ),
            MenuItem(
              label: Strings.addToQueue,
              icon: IconId.queue,
              onPressed: () => _run(() => playback.enqueue(track)),
            ),
            MenuItem(
              label: liked
                  ? Strings.removeFromFavorites
                  : Strings.addToFavorites,
              icon: IconId.heart,
              onPressed: () => _run(() => library.setLiked(track.id, !liked)),
            ),
            MenuItem(
              label: Strings.addToPlaylist,
              icon: IconId.library,
              onPressed: () => setState(() => _page = _Page.playlists),
            ),
            if (widget.fromPlaylistId != null)
              MenuItem(
                label: Strings.removeFromPlaylist,
                icon: IconId.close,
                onPressed: () => _run(
                  () => library.removeFromPlaylist(
                    widget.fromPlaylistId!,
                    track.id,
                  ),
                ),
              ),
            if (_canShowFolder)
              MenuItem(
                label: Strings.showInFolder,
                icon: IconId.down,
                onPressed: () => _run(_showInFolder),
              ),
          ],
        );
      case _Page.playlists:
        return MenuPanel(
          semanticLabel: Strings.addToPlaylist,
          title: Strings.addToPlaylist,
          children: [
            MenuItem(
              label: Strings.back,
              autofocus: true,
              onPressed: () => setState(() => _page = _Page.actions),
            ),
            for (final playlist in library.playlists)
              MenuItem(
                label: playlist.name,
                onPressed: () =>
                    _run(() => library.addToPlaylist(playlist.id, track.id)),
              ),
            MenuItem(
              label: Strings.newPlaylist,
              icon: IconId.check,
              onPressed: () => setState(() => _page = _Page.create),
            ),
          ],
        );
      case _Page.create:
        return MenuPanel(
          semanticLabel: Strings.newPlaylist,
          title: Strings.newPlaylist,
          children: [
            MenuTextField(
              controller: _name,
              hint: Strings.playlistName,
              onSubmitted: _create,
            ),
            MenuItem(
              label: Strings.createPlaylist,
              onPressed: () => _create(_name.text),
            ),
            MenuItem(
              label: Strings.back,
              onPressed: () => setState(() => _page = _Page.playlists),
            ),
          ],
        );
    }
  }
}
