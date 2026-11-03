import 'package:flutter/material.dart';

import '../../components/icon.dart';
import '../../components/icon_data.dart';
import '../../components/pressable.dart';
import '../../settings/choices.dart';
import '../../strings.dart';
import '../../theme/accents.dart';
import '../../theme/colors.dart';
import '../../theme/material_palette.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../theme/themes.dart';

({Color accent, Color onAccent}) swatchColors(
  AccentChoice choice,
  AltynemelThemeId theme,
  DesignStyle design,
) {
  if (design == DesignStyle.material) {
    final scheme = materialScheme(theme, choice);
    return (accent: scheme.primary, onAccent: scheme.onPrimary);
  }
  final pair = accentPair(choice, theme);
  if (pair != null) return (accent: pair.$1, onAccent: pair.$2);
  final base = colorsFor(theme);
  return (accent: base.accent, onAccent: base.onAccent);
}

class AccentSwatches extends StatelessWidget {
  const AccentSwatches({
    super.key,
    required this.selected,
    required this.theme,
    required this.design,
    required this.onSelected,
  });

  final AccentChoice selected;
  final AltynemelThemeId theme;
  final DesignStyle design;
  final ValueChanged<AccentChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final text = AltynemelTextStyles.of(context);
    final colors = AltynemelColors.of(context);
    final duration = motionDuration(context, motionQuick);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Wrap(
        spacing: space4,
        runSpacing: space3,
        children: [
          for (final choice in AccentChoice.values)
            Builder(
              builder: (context) {
                final paint = swatchColors(choice, theme, design);
                final isSelected = choice == selected;
                final caption = choice == AccentChoice.theme
                    ? Strings.setupAccentDefault
                    : accentLabels[choice]!;
                return SizedBox(
                  width: 72,
                  child: Pressable(
                    onPressed: () => onSelected(choice),
                    radius: 16,
                    semanticLabel: accentLabels[choice]!,
                    selected: isSelected,
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: duration,
                            curve: motionCurve,
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: paint.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? colors.ink
                                    : state.hovered
                                    ? colors.lineStrong
                                    : colors.line,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? AltynemelIcon(
                                    IconId.check,
                                    size: 22,
                                    color: paint.onAccent,
                                    strokeWidth: 2.4,
                                  )
                                : null,
                          ),
                          const SizedBox(height: space1),
                          Text(
                            caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: text.caption.copyWith(
                              color: isSelected ? colors.ink : colors.inkMuted,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
