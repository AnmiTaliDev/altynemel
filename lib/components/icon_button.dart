import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
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
  });

  final IconId icon;
  final String label;
  final VoidCallback? onPressed;
  final bool? pressed;
  final bool compact;
  final bool filled;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final size = compact ? targetPointer : targetMin;
    return Pressable(
      onPressed: onPressed,
      radius: size / 2,
      semanticLabel: label,
      toggled: pressed,
      builder: (context, state) {
        final Color foreground;
        if (!state.enabled) {
          foreground = colors.inkDisabled;
        } else if (pressed == false) {
          foreground = colors.inkMuted;
        } else {
          foreground = colors.ink;
        }
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: state.hovered && state.enabled
                ? colors.surfaceHigh
                : Colors.transparent,
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
              if (pressed == true)
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
  }
}
