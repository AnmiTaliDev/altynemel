import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/media_tile.dart';
import '../components/pill_tabs.dart';
import '../components/screen_header.dart';
import '../components/track_table.dart';
import '../library/album.dart';
import '../library/artist.dart';
import '../library/track.dart';
import '../strings.dart';
import '../theme/spacing.dart';
import 'album_column.dart';
import 'empty_state.dart';

enum LibraryTab { albums, artists, tracks }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.albums,
    required this.artists,
    required this.tracks,
    required this.currentTrackId,
    required this.isPlaying,
    required this.selectedTrackId,
    required this.onSelectTrack,
    required this.onPlayTrack,
    required this.onTrackMore,
    required this.onOpenAlbum,
    required this.onOpenArtist,
    required this.onOpenSettings,
    this.initialTab = LibraryTab.albums,
  });

  final List<Album> albums;
  final List<Artist> artists;
  final List<Track> tracks;
  final String? currentTrackId;
  final bool isPlaying;
  final String? selectedTrackId;
  final ValueChanged<Track> onSelectTrack;
  final ValueChanged<Track> onPlayTrack;
  final ValueChanged<Track> onTrackMore;
  final ValueChanged<Album> onOpenAlbum;
  final ValueChanged<Artist> onOpenArtist;
  final VoidCallback onOpenSettings;
  final LibraryTab initialTab;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late LibraryTab _tab = widget.initialTab;

  bool get _isEmpty =>
      widget.albums.isEmpty && widget.artists.isEmpty && widget.tracks.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(space6, space5, space6, space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: Strings.library),
            const SizedBox(height: space5),
            EmptyState(
              title: Strings.libraryEmpty,
              hint: Strings.libraryEmptyHint,
              action: AltynemelButton(
                label: Strings.openSettings,
                kind: ButtonKind.primary,
                onPressed: widget.onOpenSettings,
              ),
            ),
          ],
        ),
      );
    }
    final showAlbum = showAlbumColumn(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(space6, space5, space6, space5),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(title: Strings.library),
                const SizedBox(height: space5),
                PillTabs<LibraryTab>(
                  semanticLabel: Strings.libraryViews,
                  selected: _tab,
                  onSelected: (value) => setState(() => _tab = value),
                  options: const [
                    PillOption(value: LibraryTab.albums, label: Strings.albums),
                    PillOption(
                      value: LibraryTab.artists,
                      label: Strings.artists,
                    ),
                    PillOption(value: LibraryTab.tracks, label: Strings.tracks),
                  ],
                ),
              ],
            ),
          ),
        ),
        switch (_tab) {
          LibraryTab.albums => _tiles([
            for (final album in widget.albums)
              MediaTile(
                title: album.title,
                subtitle: album.artist,
                semanticLabel: Strings.albumTile(album.title, album.artist),
                onPressed: () => widget.onOpenAlbum(album),
              ),
          ]),
          LibraryTab.artists => _tiles([
            for (final artist in widget.artists)
              MediaTile(
                title: artist.name,
                subtitle: Strings.tracksOf(artist.trackCount),
                semanticLabel: Strings.artistTile(
                  artist.name,
                  artist.trackCount,
                ),
                onPressed: () => widget.onOpenArtist(artist),
              ),
          ]),
          LibraryTab.tracks => _trackList(showAlbum),
        },
      ],
    );
  }

  Widget _tiles(List<Widget> children) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        space6 - space2,
        0,
        space6 - space2,
        space6,
      ),
      sliver: SliverToBoxAdapter(
        child: Wrap(spacing: space2, runSpacing: space2, children: children),
      ),
    );
  }

  Widget _trackList(bool showAlbum) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: space6),
          sliver: SliverToBoxAdapter(
            child: Semantics(
              container: true,
              label: Strings.tracks,
              child: TrackTableHeader(showAlbum: showAlbum),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(space6, 0, space6, space6),
          sliver: SliverList.builder(
            itemCount: widget.tracks.length,
            itemBuilder: (context, index) {
              final track = widget.tracks[index];
              final current = track.id == widget.currentTrackId;
              return TrackTableRow(
                number: index + 1,
                title: track.title,
                artist: track.artist,
                album: track.album,
                duration: track.duration,
                showAlbum: showAlbum,
                isCurrent: current,
                isPlaying: current && widget.isPlaying,
                isSelected: track.id == widget.selectedTrackId,
                onSelect: () => widget.onSelectTrack(track),
                onPlay: () => widget.onPlayTrack(track),
                onMore: () => widget.onTrackMore(track),
              );
            },
          ),
        ),
      ],
    );
  }
}
