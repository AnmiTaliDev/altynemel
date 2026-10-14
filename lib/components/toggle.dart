import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'focus_ring.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';

class Toggle extends StatelessWidget {
  const Toggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.disabledReason,
  });

  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final enabled = onChanged != null;
    final secondary = enabled ? description : (disabledReason ?? description);
    return Pressable(
      onPressed: enabled ? () => onChanged!(!value) : null,
      radius: radiusPill,
      drawFocusRing: false,
      toggled: value,
      semanticLabel: secondary == null ? title : '$title, $secondary',
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(vertical: space2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.line, width: borderWidth),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.bodyStrong.copyWith(
                        color: enabled ? colors.ink : colors.inkDisabled,
                      ),
                    ),
                    if (secondary != null)
                      Text(
                        secondary,
                        style: text.caption.copyWith(
                          color: enabled ? colors.inkMuted : colors.inkDisabled,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: space4),
              FocusRing(
                visible: state.focused,
                radius: radiusPill,
                child: _Switch(value: value, enabled: enabled),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.value, required this.enabled});

  final bool value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final borderColor = !enabled
        ? colors.inkDisabled
        : (value ? colors.ink : colors.lineStrong);
    final knobColor = value
        ? (enabled ? colors.ground : colors.ground)
        : (enabled ? colors.inkMuted : colors.inkDisabled);
    final fill = value
        ? (enabled ? colors.ink : colors.inkDisabled)
        : Colors.transparent;
    return Container(
      width: 56,
      height: 32,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: borderRadiusPill,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: AnimatedAlign(
        duration: motionDuration(context, motionQuick),
        curve: motionCurve,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: knobColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: value
              ? AltynemelIcon(
                  IconId.check,
                  size: 16,
                  color: enabled ? colors.ink : colors.inkDisabled,
                  strokeWidth: 2.2,
                )
              : null,
        ),
      ),
    );
  }
}
