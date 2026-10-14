import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'cover_art.dart';
import 'icon_button.dart';
import 'icon_data.dart';
import 'pressable.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    required this.isPlaying,
    required this.progress,
    required this.onOpen,
    required this.onPlayPause,
    this.image,
    this.albumName,
  });

  final String title;
  final String artist;
  final ImageProvider? image;
  final String? albumName;
  final bool isPlaying;
  final double progress;
  final VoidCallback? onOpen;
  final VoidCallback? onPlayPause;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Stack(
      children: [
        Pressable(
          onPressed: onOpen,
          radius: radiusCard,
          semanticLabel: Strings.nowPlayingCard(title, artist),
          builder: (context, state) {
            return ClipRRect(
              borderRadius: borderRadiusCard,
              child: Container(
                color: colors.surfaceHigh,
                padding: const EdgeInsets.fromLTRB(
                  space2,
                  space2,
                  space2,
                  space3,
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        CoverArt(size: 48, image: image, albumName: albumName),
                        const SizedBox(width: space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: text.bodyStrong),
                              Text(
                                artist,
                                style: text.caption.copyWith(
                                  color: colors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: space3 + targetMin),
                      ],
                    ),
                    Positioned(
                      left: -space2,
                      right: -space2,
                      bottom: -space3,
                      height: 3,
                      child: ExcludeSemantics(
                        child: ColoredBox(
                          color: colors.line,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: ColoredBox(color: colors.ink),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          right: space2,
          top: space2,
          child: AltynemelIconButton(
            icon: isPlaying ? IconId.pause : IconId.play,
            label: isPlaying ? Strings.pause : Strings.play,
            filled: !isPlaying,
            onPressed: onPlayPause,
          ),
        ),
      ],
    );
  }
}
