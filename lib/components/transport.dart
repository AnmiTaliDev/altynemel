import 'package:flutter/material.dart';

import '../player/repeat_setting.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'icon.dart';
import 'icon_button.dart';
import 'icon_data.dart';
import 'pressable.dart';

enum TransportVariant { accent, bar }

class Transport extends StatelessWidget {
  const Transport({
    super.key,
    required this.isPlaying,
    required this.shuffle,
    required this.repeat,
    required this.onShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onRepeat,
    this.variant = TransportVariant.accent,
  });

  final bool isPlaying;
  final bool shuffle;
  final RepeatSetting repeat;
  final VoidCallback? onShuffle;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onRepeat;
  final TransportVariant variant;

  @override
  Widget build(BuildContext context) {
    final compact = variant == TransportVariant.bar;
    final repeatLabel = switch (repeat) {
      RepeatSetting.off => Strings.repeat,
      RepeatSetting.all => Strings.repeatAll,
      RepeatSetting.one => Strings.repeatOne,
    };
    return Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: compact
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        AltynemelIconButton(
          icon: IconId.shuffle,
          label: Strings.shuffle,
          pressed: shuffle,
          compact: compact,
          onPressed: onShuffle,
        ),
        if (compact) const SizedBox(width: space2),
        AltynemelIconButton(
          icon: IconId.prev,
          label: Strings.previousTrack,
          compact: compact,
          onPressed: onPrevious,
        ),
        if (compact) const SizedBox(width: space2),
        _PlayButton(
          isPlaying: isPlaying,
          variant: variant,
          onPressed: onPlayPause,
        ),
        if (compact) const SizedBox(width: space2),
        AltynemelIconButton(
          icon: IconId.next,
          label: Strings.nextTrack,
          compact: compact,
          onPressed: onNext,
        ),
        if (compact) const SizedBox(width: space2),
        AltynemelIconButton(
          icon: IconId.repeat,
          label: repeatLabel,
          pressed: repeat != RepeatSetting.off,
          compact: compact,
          onPressed: onRepeat,
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.variant,
    required this.onPressed,
  });

  final bool isPlaying;
  final TransportVariant variant;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final accent = variant == TransportVariant.accent;
    final size = accent ? targetLg : targetMin;
    final iconSize = accent ? 28.0 : 22.0;
    return Pressable(
      onPressed: onPressed,
      radius: size / 2,
      semanticLabel: isPlaying ? Strings.pause : Strings.play,
      builder: (context, state) {
        final enabled = state.enabled;
        final foreground = !enabled
            ? colors.inkDisabled
            : (accent ? colors.onAccent : colors.ground);
        final background = !enabled
            ? colors.line
            : (accent
                  ? colors.accent
                  : (state.hovered ? colors.inkMuted : colors.ink));
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadiusPill,
          ),
          alignment: Alignment.center,
          child: isPlaying
              ? AltynemelIcon(
                  IconId.pause,
                  size: iconSize,
                  color: foreground,
                  strokeWidth: 2.5,
                )
              : AltynemelIcon(
                  IconId.play,
                  size: iconSize,
                  color: foreground,
                  filled: true,
                ),
        );
      },
    );
  }
}
