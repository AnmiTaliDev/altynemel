import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
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
                child: AltynemelStyle.of(context).material
                    ? _MaterialSwitch(value: value, enabled: enabled)
                    : _Switch(value: value, enabled: enabled),
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

class _MaterialSwitch extends StatelessWidget {
  const _MaterialSwitch({required this.value, required this.enabled});

  final bool value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = AltynemelStyle.of(context).scheme!;
    final Color track;
    final Color border;
    final Color thumb;
    if (!enabled) {
      track = value
          ? scheme.onSurface.withValues(alpha: 0.12)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.12);
      border = value
          ? Colors.transparent
          : scheme.onSurface.withValues(alpha: 0.12);
      thumb = value ? scheme.surface : scheme.onSurface.withValues(alpha: 0.38);
    } else if (value) {
      track = scheme.primary;
      border = Colors.transparent;
      thumb = scheme.onPrimary;
    } else {
      track = scheme.surfaceContainerHighest;
      border = scheme.outline;
      thumb = scheme.outline;
    }
    final duration = motionDuration(context, motionQuick);
    final size = value ? 24.0 : 16.0;
    return AnimatedContainer(
      duration: duration,
      curve: motionCurve,
      width: 52,
      height: 32,
      decoration: BoxDecoration(
        color: track,
        borderRadius: borderRadiusPill,
        border: Border.all(color: border, width: 2),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: motionCurve,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: duration,
          curve: motionCurve,
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: value ? 2 : 6),
          decoration: BoxDecoration(color: thumb, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: value
              ? AltynemelIcon(
                  IconId.check,
                  size: 16,
                  color: enabled
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.38),
                  strokeWidth: 2.2,
                )
              : null,
        ),
      ),
    );
  }
}
