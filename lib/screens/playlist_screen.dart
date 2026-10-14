import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/cover_art.dart';
import '../components/icon_data.dart';
import '../components/track_table.dart';
import '../format/time_format.dart';
import '../library/cover_image.dart';
import '../library/track.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'album_column.dart';
import 'empty_state.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({
    super.key,
    required this.title,
    required this.tracks,
    required this.currentTrackId,
    required this.isPlaying,
    required this.selectedTrackId,
    required this.onPlayPause,
    required this.onSelectTrack,
    required this.onPlayTrack,
    required this.onTrackMore,
    this.emptyTitle,
    this.emptyHint,
  });

  final String title;
  final List<Track> tracks;
  final String? currentTrackId;
  final bool isPlaying;
  final String? selectedTrackId;
  final VoidCallback onPlayPause;
  final ValueChanged<Track> onSelectTrack;
  final ValueChanged<Track> onPlayTrack;
  final ValueChanged<Track> onTrackMore;
  final String? emptyTitle;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final showAlbum =
        MediaQuery.sizeOf(context).width >= albumColumnHiddenBelow;
    final total = tracks.fold(Duration.zero, (sum, t) => sum + t.duration);
    final summary =
        '${Strings.songCount(tracks.length)} · ${shortDuration(total)}';
    final playingFromHere = tracks.any((t) => t.id == currentTrackId);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(space6, space5, space6, 0),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: space5),
              child: Wrap(
                spacing: space5,
                runSpacing: space5,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  const CoverArt(size: 160),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.playlist,
                        style: text.label.copyWith(color: colors.inkMuted),
                      ),
                      const SizedBox(height: space2),
                      Semantics(
                        header: true,
                        child: Text(title, style: text.displayLg),
                      ),
                      const SizedBox(height: space2),
                      Text(
                        summary,
                        style: text.caption.copyWith(color: colors.inkMuted),
                      ),
                      const SizedBox(height: space4),
                      AltynemelButton(
                        label: playingFromHere && isPlaying
                            ? Strings.pause
                            : Strings.play,
                        kind: ButtonKind.primary,
                        icon: playingFromHere && isPlaying
                            ? IconId.pause
                            : IconId.play,
                        filledIcon: !(playingFromHere && isPlaying),
                        onPressed: tracks.isEmpty ? null : onPlayPause,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (tracks.isEmpty && emptyTitle != null)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: space6),
            sliver: SliverToBoxAdapter(
              child: EmptyState(title: emptyTitle!, hint: emptyHint ?? ''),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: space6),
            sliver: SliverToBoxAdapter(
              child: Semantics(
                container: true,
                label: Strings.songsIn(title),
                child: TrackTableHeader(showAlbum: showAlbum),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(space6, 0, space6, space6),
          sliver: SliverList.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final current = track.id == currentTrackId;
              return TrackTableRow(
                number: index + 1,
                title: track.title,
                artist: track.artist,
                album: track.album,
                image: coverImage(track.coverPath, width: 80),
                duration: track.duration,
                showAlbum: showAlbum,
                isCurrent: current,
                isPlaying: current && isPlaying,
                isSelected: track.id == selectedTrackId,
                onSelect: () => onSelectTrack(track),
                onPlay: () => onPlayTrack(track),
                onMore: () => onTrackMore(track),
              );
            },
          ),
        ),
      ],
    );
  }
}
