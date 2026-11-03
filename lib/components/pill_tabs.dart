import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';

class PillOption<T> {
  const PillOption({required this.value, required this.label});

  final T value;
  final String label;
}

class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
  });

  final List<PillOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String semanticLabel;

  Widget _materialChips(
    BuildContext context,
    ColorScheme scheme,
    AltynemelTextStyles text,
  ) {
    final shape = BorderRadius.circular(8);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Wrap(
        spacing: space2,
        runSpacing: space2,
        children: [
          for (final option in options)
            Pressable(
              onPressed: () => onSelected(option.value),
              radius: 8,
              semanticLabel: option.label,
              selected: option.value == selected,
              builder: (context, state) {
                final isSelected = option.value == selected;
                final foreground = isSelected
                    ? scheme.onSecondaryContainer
                    : scheme.onSurfaceVariant;
                final base = isSelected
                    ? scheme.secondaryContainer
                    : Colors.transparent;
                final layer = state.pressed
                    ? 0.12
                    : (state.hovered || state.focused)
                    ? 0.08
                    : 0.0;
                return Container(
                  constraints: const BoxConstraints(
                    minHeight: 32,
                    minWidth: 48,
                  ),
                  padding: EdgeInsets.only(
                    left: isSelected ? space2 : space3,
                    right: space3,
                  ),
                  decoration: BoxDecoration(
                    color: layer == 0
                        ? base
                        : Color.alphaBlend(
                            foreground.withValues(alpha: layer),
                            base,
                          ),
                    borderRadius: shape,
                    border: isSelected
                        ? null
                        : Border.all(color: scheme.outline, width: borderWidth),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        AltynemelIcon(
                          IconId.check,
                          size: 18,
                          color: foreground,
                          strokeWidth: 2,
                        ),
                        const SizedBox(width: space2),
                      ],
                      Flexible(
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: text.bodyStrong.copyWith(color: foreground),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    if (style.material) return _materialChips(context, style.scheme!, text);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Wrap(
        spacing: space2,
        runSpacing: space2,
        children: [
          for (final option in options)
            Pressable(
              onPressed: () => onSelected(option.value),
              radius: radiusPill,
              semanticLabel: option.label,
              selected: option.value == selected,
              builder: (context, state) {
                final isSelected = option.value == selected;
                return Container(
                  constraints: const BoxConstraints(
                    minHeight: targetPointer,
                    minWidth: targetPointer,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: space4),
                  decoration: BoxDecoration(
                    color: isSelected || state.hovered
                        ? colors.surfaceHigh
                        : Colors.transparent,
                    borderRadius: borderRadiusPill,
                    border: Border.all(
                      color: isSelected ? colors.ink : colors.lineStrong,
                      width: borderWidth,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        AltynemelIcon(
                          IconId.check,
                          size: 16,
                          color: colors.ink,
                          strokeWidth: 2.2,
                        ),
                        const SizedBox(width: space1),
                      ],
                      Flexible(
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: text.bodyStrong.copyWith(
                            color: isSelected ? colors.ink : colors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
