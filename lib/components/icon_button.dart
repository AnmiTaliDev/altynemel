import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';

class AltynemelIconButton extends StatelessWidget {
  const AltynemelIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.pressed,
    this.compact = false,
    this.filled = false,
    this.iconSize = 24,
    this.hint,
    this.badge,
  });

  final IconId icon;
  final String label;
  final VoidCallback? onPressed;
  final bool? pressed;
  final bool compact;
  final bool filled;
  final double iconSize;
  final String? hint;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final size = compact ? targetPointer : targetMin;
    final style = AltynemelStyle.of(context);
    final material = style.material;
    final button = Pressable(
      onPressed: onPressed,
      radius: size / 2,
      semanticLabel: label,
      toggled: pressed,
      builder: (context, state) {
        final Color foreground;
        Color fill = Colors.transparent;
        if (material) {
          final scheme = style.scheme!;
          final Color base;
          if (!state.enabled) {
            foreground = scheme.onSurface.withValues(alpha: 0.38);
            base = Colors.transparent;
          } else if (filled) {
            foreground = scheme.onPrimary;
            base = scheme.primary;
          } else if (pressed == true) {
            foreground = scheme.primary;
            base = Colors.transparent;
          } else {
            foreground = scheme.onSurfaceVariant;
            base = Colors.transparent;
          }
          final layer = !state.enabled
              ? 0.0
              : state.pressed
              ? 0.12
              : (state.hovered || state.focused)
              ? 0.08
              : 0.0;
          fill = layer == 0
              ? base
              : Color.alphaBlend(foreground.withValues(alpha: layer), base);
        } else {
          if (!state.enabled) {
            foreground = colors.inkDisabled;
          } else if (pressed == false) {
            foreground = colors.inkMuted;
          } else {
            foreground = colors.ink;
          }
          if (state.hovered && state.enabled) fill = colors.surfaceHigh;
        }
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: borderRadiusPill,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AltynemelIcon(
                icon,
                size: iconSize,
                color: foreground,
                filled: filled,
              ),
              if (badge != null)
                Positioned(
                  right: compact ? 2 : 6,
                  bottom: compact ? 0 : 3,
                  child: Text(
                    badge!,
                    style: AltynemelTextStyles.of(
                      context,
                    ).label.copyWith(color: foreground),
                  ),
                ),
              if (pressed == true && badge == null)
                Positioned(
                  bottom: compact ? 3 : 6,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: foreground,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    final message = hint;
    if (message == null) return button;
    return Tooltip(message: message, excludeFromSemantics: true, child: button);
  }
}
