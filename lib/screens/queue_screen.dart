import 'package:flutter/material.dart';

import '../components/screen_header.dart';
import '../components/track_table.dart';
import '../library/cover_image.dart';
import '../library/track.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'album_column.dart';
import 'empty_state.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({
    super.key,
    required this.tracks,
    required this.currentIndex,
    required this.isPlaying,
    required this.selectedTrackId,
    required this.onSelectTrack,
    required this.onPlayTrack,
    required this.onTrackMore,
  });

  final List<Track> tracks;
  final int? currentIndex;
  final bool isPlaying;
  final String? selectedTrackId;
  final ValueChanged<Track> onSelectTrack;
  final ValueChanged<Track> onPlayTrack;
  final ValueChanged<Track> onTrackMore;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(space6, space5, space6, space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(title: Strings.queue),
            SizedBox(height: space5),
            EmptyState(title: Strings.queueEmpty, hint: Strings.queueEmptyHint),
          ],
        ),
      );
    }
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final showAlbum = showAlbumColumn(context);
    final current = currentIndex;
    final upcoming = current == null
        ? tracks
        : tracks.sublist((current + 1).clamp(0, tracks.length));
    Widget row(Track track, int number, bool isCurrent) {
      return TrackTableRow(
        number: number,
        title: track.title,
        artist: track.artist,
        album: track.album,
        image: coverImage(track.coverPath, width: 80),
        duration: track.duration,
        showAlbum: showAlbum,
        isCurrent: isCurrent,
        isPlaying: isCurrent && isPlaying,
        isSelected: track.id == selectedTrackId,
        onSelect: () => onSelectTrack(track),
        onPlay: () => onPlayTrack(track),
        onMore: () => onTrackMore(track),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(space6, space5, space6, space5),
          sliver: const SliverToBoxAdapter(
            child: ScreenHeader(title: Strings.queue),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: space6),
          sliver: SliverToBoxAdapter(
            child: TrackTableHeader(showAlbum: showAlbum),
          ),
        ),
        if (current != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(space6, space2, space6, 0),
            sliver: SliverToBoxAdapter(
              child: row(tracks[current], current + 1, true),
            ),
          ),
        if (upcoming.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              space6 + space3,
              space5,
              space6,
              space2,
            ),
            sliver: SliverToBoxAdapter(
              child: Semantics(
                header: true,
                child: Text(
                  Strings.nextUp,
                  style: text.label.copyWith(color: colors.inkMuted),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(space6, 0, space6, space6),
            sliver: SliverList.builder(
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final offset = current == null ? 0 : current + 1;
                return row(upcoming[index], offset + index + 1, false);
              },
            ),
          ),
        ],
      ],
    );
  }
}
