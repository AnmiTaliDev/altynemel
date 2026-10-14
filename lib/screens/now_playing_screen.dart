import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/album_text.dart';
import '../components/artist_text.dart';
import '../components/cover_art.dart';
import '../components/icon.dart';
import '../components/icon_button.dart';
import '../components/icon_data.dart';
import '../components/menu.dart';
import '../components/progress_bar.dart';
import '../components/time_label.dart';
import '../components/transport.dart';
import '../format/time_format.dart';
import '../player/repeat_setting.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

const double nowPlayingWideFrom = 900;

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.liked,
    required this.onToggleLike,
    required this.isPlaying,
    required this.shuffle,
    required this.repeat,
    required this.onShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onRepeat,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.volume,
    required this.onVolume,
    required this.onQueue,
    required this.onCollapse,
    required this.onMore,
    this.volumeStep = 5,
    this.image,
    this.album,
    this.albumId,
  });

  final String title;
  final String artist;
  final String? album;
  final String? albumId;
  final ImageProvider? image;
  final bool liked;
  final VoidCallback onToggleLike;
  final bool isPlaying;
  final bool shuffle;
  final RepeatSetting repeat;
  final VoidCallback onShuffle;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onRepeat;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final int volume;
  final int volumeStep;
  final ValueChanged<int> onVolume;
  final VoidCallback onQueue;
  final VoidCallback onCollapse;
  final ValueChanged<Rect> onMore;

  Widget _top(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Row(
      children: [
        AltynemelIconButton(
          icon: IconId.down,
          label: Strings.collapse,
          hint: Strings.withShortcut(Strings.collapse, 'Esc'),
          onPressed: onCollapse,
        ),
        Expanded(
          child: Text(
            Strings.nowPlaying,
            textAlign: TextAlign.center,
            style: text.label.copyWith(color: colors.inkMuted),
          ),
        ),
        Builder(
          builder: (context) => AltynemelIconButton(
            icon: IconId.more,
            label: Strings.moreAbout(title),
            onPressed: () => onMore(anchorRect(context)),
          ),
        ),
      ],
    );
  }

  Widget _details(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final seconds = position.inMilliseconds / 1000;
    final maxSeconds = duration.inMilliseconds / 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(title, style: text.displayXl),
        ),
        const SizedBox(height: space2),
        ArtistText(artist, style: text.bodyLg),
        if (album != null) ...[
          const SizedBox(height: space1),
          AlbumText(
            album!,
            albumId: albumId,
            style: text.caption.copyWith(color: colors.inkMuted),
          ),
        ],
        const SizedBox(height: space5),
        ProgressBar(
          value: seconds,
          max: maxSeconds,
          semanticLabel: Strings.seek,
          semanticValueOf: (value) => spokenProgress(
            Duration(milliseconds: (value * 1000).round()),
            duration,
          ),
          onChanged: (value) =>
              onSeek(Duration(milliseconds: (value * 1000).round())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [TimeLabel(position), TimeLabel(duration)],
        ),
        const SizedBox(height: space5),
        Transport(
          isPlaying: isPlaying,
          shuffle: shuffle,
          repeat: repeat,
          onShuffle: onShuffle,
          onPrevious: onPrevious,
          onPlayPause: onPlayPause,
          onNext: onNext,
          onRepeat: onRepeat,
        ),
        const SizedBox(height: space5),
        Row(
          children: [
            AltynemelIconButton(
              icon: IconId.heart,
              label: liked
                  ? Strings.removeFromFavorites
                  : Strings.addToFavorites,
              pressed: liked,
              onPressed: onToggleLike,
            ),
            AltynemelIconButton(
              icon: IconId.queue,
              label: Strings.queue,
              onPressed: onQueue,
            ),
            const Spacer(),
            AltynemelIcon(IconId.volume, color: colors.inkMuted),
            const SizedBox(width: space2),
            SizedBox(
              width: 140,
              child: ProgressBar(
                value: volume.toDouble(),
                max: 100,
                step: volumeStep.toDouble(),
                semanticLabel: Strings.volume,
                semanticValueOf: (value) => Strings.percent(value.round()),
                onChanged: (value) => onVolume(value.round()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.nowPlaying,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= nowPlayingWideFrom;
          final coverSize = wide
              ? 320.0
              : math.max(
                  160.0,
                  math.min(240.0, constraints.maxWidth - 2 * space5),
                );
          final cover = CoverArt(
            size: coverSize,
            image: image,
            albumName: album ?? title,
            shape: CoverShape.arch,
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(space4, space2, space4, 0),
                child: _top(context),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, inner) => SingleChildScrollView(
                    padding: const EdgeInsets.all(space5),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, inner.maxHeight - 2 * space5),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: wide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    cover,
                                    const SizedBox(width: space7),
                                    Expanded(child: _details(context)),
                                  ],
                                )
                              : Column(
                                  children: [
                                    cover,
                                    const SizedBox(height: space5),
                                    _details(context),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
