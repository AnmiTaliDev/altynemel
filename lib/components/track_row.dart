import 'package:flutter/material.dart';

import '../format/time_format.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_button.dart';
import 'icon_data.dart';
import 'pressable.dart';
import 'time_label.dart';

enum TrackAvailability { available, downloaded, unavailableOffline }

class AvailabilityFlag extends StatelessWidget {
  const AvailabilityFlag(this.availability, {super.key});

  final TrackAvailability availability;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final (icon, word, color) = switch (availability) {
      TrackAvailability.downloaded => (
        IconId.check,
        Strings.downloaded,
        colors.ok,
      ),
      TrackAvailability.unavailableOffline => (
        IconId.alert,
        Strings.unavailableOffline,
        colors.alert,
      ),
      TrackAvailability.available => (null, '', colors.ink),
    };
    if (icon == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AltynemelIcon(icon, size: 16, color: color),
        const SizedBox(width: space1),
        Flexible(
          child: Text(word, style: text.caption.copyWith(color: color)),
        ),
      ],
    );
  }
}

class TrackRow extends StatelessWidget {
  const TrackRow({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    required this.onPressed,
    required this.onMore,
    this.number,
    this.album,
    this.isPlaying = false,
    this.availability = TrackAvailability.available,
  });

  final String title;
  final String artist;
  final String? album;
  final Duration duration;
  final int? number;
  final bool isPlaying;
  final TrackAvailability availability;
  final VoidCallback? onPressed;
  final VoidCallback? onMore;

  String _spokenLabel() {
    final parts = [
      title,
      artist,
      ?album,
      spokenDuration(duration),
      if (availability == TrackAvailability.downloaded) Strings.downloaded,
      if (availability == TrackAvailability.unavailableOffline)
        Strings.unavailableOffline,
      if (isPlaying) Strings.playingNow,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final unavailable = availability == TrackAvailability.unavailableOffline;
    final second = [artist, ?album].join(' · ');
    return Stack(
      children: [
        Pressable(
          onPressed: unavailable ? null : onPressed,
          radius: 0,
          semanticLabel: _spokenLabel(),
          selected: isPlaying,
          builder: (context, state) {
            return Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.fromLTRB(
                space4,
                space2,
                targetMin + space3,
                space2,
              ),
              decoration: BoxDecoration(
                color: isPlaying
                    ? colors.surface
                    : (state.hovered ? colors.surfaceHigh : Colors.transparent),
                border: Border(
                  bottom: BorderSide(color: colors.line, width: borderWidth),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: isPlaying
                          ? AltynemelIcon(
                              IconId.playing,
                              size: 20,
                              color: colors.accent,
                            )
                          : Text(
                              number?.toString() ?? '',
                              style: text.time.copyWith(color: colors.inkMuted),
                            ),
                    ),
                  ),
                  const SizedBox(width: space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.bodyStrong.copyWith(
                            color: unavailable
                                ? colors.inkDisabled
                                : colors.ink,
                          ),
                        ),
                        Wrap(
                          spacing: space2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              second,
                              style: text.caption.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                            AvailabilityFlag(availability),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: space3),
                  TimeLabel(duration),
                ],
              ),
            );
          },
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: AltynemelIconButton(
              icon: IconId.more,
              label: Strings.moreAbout(title),
              onPressed: onMore,
            ),
          ),
        ),
      ],
    );
  }
}
