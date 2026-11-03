import 'package:flutter/material.dart';

import '../../components/button.dart';
import '../../components/cover_art.dart';
import '../../components/icon.dart';
import '../../components/icon_data.dart';
import '../../components/pressable.dart';
import '../../components/progress_bar.dart';
import '../../settings/choices.dart';
import '../../strings.dart';
import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../theme/themes.dart';

class StyleCard extends StatelessWidget {
  const StyleCard({
    super.key,
    required this.design,
    required this.title,
    required this.hint,
    required this.selected,
    required this.themeId,
    required this.accent,
    required this.onSelected,
  });

  final DesignStyle design;
  final String title;
  final String hint;
  final bool selected;
  final AltynemelThemeId themeId;
  final AccentChoice accent;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final duration = motionDuration(context, motionQuick);
    return Pressable(
      onPressed: onSelected,
      radius: 20,
      semanticLabel: '$title. $hint',
      selected: selected,
      builder: (context, state) {
        return AnimatedContainer(
          duration: duration,
          curve: motionCurve,
          padding: const EdgeInsets.all(space3),
          decoration: BoxDecoration(
            color: selected || state.hovered
                ? colors.surfaceHigh
                : colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? colors.accent : colors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: IgnorePointer(
                  child: StylePreview(
                    design: design,
                    themeId: themeId,
                    accent: accent,
                  ),
                ),
              ),
              const SizedBox(height: space3),
              Row(
                children: [
                  _Radio(selected: selected, colors: colors),
                  const SizedBox(width: space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: text.bodyStrong),
                        Text(
                          hint,
                          style: text.caption.copyWith(color: colors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.colors});

  final bool selected;
  final AltynemelColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? colors.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.accent : colors.lineStrong,
          width: 2,
        ),
      ),
      child: selected
          ? AltynemelIcon(
              IconId.check,
              size: 16,
              color: colors.onAccent,
              strokeWidth: 2.4,
            )
          : null,
    );
  }
}

class StylePreview extends StatelessWidget {
  const StylePreview({
    super.key,
    required this.design,
    required this.themeId,
    required this.accent,
  });

  final DesignStyle design;
  final AltynemelThemeId themeId;
  final AccentChoice accent;

  @override
  Widget build(BuildContext context) {
    final theme = buildTheme(themeId, accent: accent, style: design);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final colors = AltynemelColors.of(context);
          final text = AltynemelTextStyles.of(context);
          return Container(
            padding: const EdgeInsets.all(space3),
            decoration: BoxDecoration(
              color: colors.ground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const CoverArt(size: 48),
                    const SizedBox(width: space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings.setupPreviewTrack,
                            style: text.bodyStrong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Strings.setupPreviewArtist,
                            style: text.caption.copyWith(
                              color: colors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ProgressBar(
                  value: 38,
                  max: 100,
                  height: 28,
                  semanticLabel: '',
                  semanticValueOf: (_) => '',
                  onChanged: (_) {},
                ),
                Wrap(
                  spacing: space2,
                  runSpacing: space2,
                  children: [
                    AltynemelButton(
                      label: Strings.setupPreviewPlay,
                      kind: ButtonKind.primary,
                      icon: IconId.play,
                      filledIcon: true,
                      onPressed: () {},
                    ),
                    AltynemelButton(
                      label: Strings.setupPreviewQueue,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
