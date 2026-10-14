import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../format/time_format.dart';
import '../player/repeat_setting.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'artist_text.dart';
import 'cover_art.dart';
import 'icon.dart';
import 'icon_button.dart';
import 'icon_data.dart';
import 'pressable.dart';
import 'progress_bar.dart';
import 'time_label.dart';
import 'transport.dart';

const double volumeHiddenBelow = 860;

class PlayerBar extends StatelessWidget {
  const PlayerBar({
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
    this.volumeStep = 5,
    this.onOpenNowPlaying,
    this.image,
    this.albumName,
  });

  final String? title;
  final String? artist;
  final ImageProvider? image;
  final String? albumName;
  final bool liked;
  final VoidCallback? onToggleLike;
  final bool isPlaying;
  final bool shuffle;
  final RepeatSetting repeat;
  final VoidCallback? onShuffle;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onRepeat;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onSeek;
  final int volume;
  final ValueChanged<int>? onVolume;
  final VoidCallback? onQueue;
  final int volumeStep;
  final VoidCallback? onOpenNowPlaying;

  Widget _trackInfo(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Row(
      children: [
        CoverArt(size: 56, image: image, albumName: albumName),
        const SizedBox(width: space3),
        Expanded(
          child: Semantics(
            liveRegion: true,
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title == null)
                  Text(
                    Strings.nothingPlaying,
                    style: text.bodyStrong.copyWith(color: colors.inkMuted),
                  )
                else ...[
                  Text(title!, style: text.bodyStrong),
                  ArtistText(
                    artist ?? '',
                    style: text.caption.copyWith(color: colors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _track(BuildContext context) {
    final open = onOpenNowPlaying;
    return Row(
      children: [
        Expanded(
          child: open == null || title == null
              ? _trackInfo(context)
              : Pressable(
                  onPressed: open,
                  radius: radiusControl,
                  semanticLabel: Strings.openNowPlaying,
                  builder: (context, state) => _trackInfo(context),
                ),
        ),
        AltynemelIconButton(
          icon: IconId.heart,
          label: liked ? Strings.removeFromFavorites : Strings.addToFavorites,
          pressed: liked,
          compact: true,
          onPressed: onToggleLike,
        ),
      ],
    );
  }

  Widget _center(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final positionSeconds = position.inMilliseconds / 1000;
    final maxSeconds = duration.inMilliseconds / 1000;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transport(
          variant: TransportVariant.bar,
          isPlaying: isPlaying,
          shuffle: shuffle,
          repeat: repeat,
          onShuffle: onShuffle,
          onPrevious: onPrevious,
          onPlayPause: onPlayPause,
          onNext: onNext,
          onRepeat: onRepeat,
        ),
        Row(
          children: [
            SizedBox(
              width: 36,
              child: TimeLabel(position, textAlign: TextAlign.right),
            ),
            const SizedBox(width: space3),
            Expanded(
              child: ProgressBar(
                value: positionSeconds,
                max: maxSeconds,
                height: targetPointer,
                gapColor: colors.surface,
                semanticLabel: Strings.seek,
                semanticValueOf: (seconds) => spokenProgress(
                  Duration(milliseconds: (seconds * 1000).round()),
                  duration,
                ),
                onChanged: onSeek == null
                    ? null
                    : (seconds) => onSeek!(
                        Duration(milliseconds: (seconds * 1000).round()),
                      ),
              ),
            ),
            const SizedBox(width: space3),
            SizedBox(width: 36, child: TimeLabel(duration)),
          ],
        ),
      ],
    );
  }

  Widget _right(BuildContext context, bool showVolume) {
    final colors = AltynemelColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AltynemelIconButton(
          icon: IconId.queue,
          label: Strings.queue,
          compact: true,
          onPressed: onQueue,
        ),
        if (showVolume) ...[
          const SizedBox(width: space2),
          AltynemelIcon(IconId.volume, color: colors.inkMuted),
          const SizedBox(width: space2),
          SizedBox(
            width: 96,
            child: ProgressBar(
              value: volume.toDouble(),
              max: 100,
              step: volumeStep.toDouble(),
              height: targetPointer,
              gapColor: colors.surface,
              semanticLabel: Strings.volume,
              semanticValueOf: (value) => Strings.percent(value.round()),
              onChanged: onVolume == null
                  ? null
                  : (value) => onVolume!(value.round()),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final showVolume = width >= volumeHiddenBelow;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.player,
      child: Container(
        constraints: const BoxConstraints(minHeight: playerBarHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: space5,
          vertical: space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.surfaceEdge, width: borderWidth),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth - 2 * space5;
            final centerWidth = math.min(
              560.0,
              math.max(showVolume ? 320.0 : 280.0, available / 2),
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _track(context)),
                const SizedBox(width: space5),
                SizedBox(width: centerWidth, child: _center(context)),
                const SizedBox(width: space5),
                Expanded(child: _right(context, showVolume)),
              ],
            );
          },
        ),
      ),
    );
  }
}
