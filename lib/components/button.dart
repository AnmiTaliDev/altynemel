import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';

enum ButtonKind { primary, secondary, text }

class AltynemelButton extends StatelessWidget {
  const AltynemelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonKind.secondary,
    this.icon,
    this.filledIcon = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final IconId? icon;
  final bool filledIcon;

  Widget _materialButton(
    BuildContext context,
    ColorScheme scheme,
    AltynemelTextStyles text,
  ) {
    return Pressable(
      onPressed: onPressed,
      radius: radiusPill,
      semanticLabel: label,
      builder: (context, state) {
        final Color foreground;
        final Color base;
        final Color overlay;
        if (!state.enabled) {
          foreground = scheme.onSurface.withValues(alpha: 0.38);
          base = kind == ButtonKind.text
              ? Colors.transparent
              : scheme.onSurface.withValues(alpha: 0.12);
          overlay = Colors.transparent;
        } else {
          switch (kind) {
            case ButtonKind.primary:
              foreground = scheme.onPrimary;
              base = scheme.primary;
              overlay = scheme.onPrimary;
            case ButtonKind.secondary:
              foreground = scheme.onSecondaryContainer;
              base = scheme.secondaryContainer;
              overlay = scheme.onSecondaryContainer;
            case ButtonKind.text:
              foreground = scheme.primary;
              base = Colors.transparent;
              overlay = scheme.primary;
          }
        }
        final layer = !state.enabled
            ? 0.0
            : state.pressed
            ? 0.12
            : (state.hovered || state.focused)
            ? 0.08
            : 0.0;
        final background = layer == 0
            ? base
            : Color.alphaBlend(overlay.withValues(alpha: layer), base);
        return Container(
          constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
          padding: EdgeInsets.symmetric(
            horizontal: kind == ButtonKind.text ? space3 : space5,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadiusPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AltynemelIcon(
                  icon!,
                  size: 18,
                  color: foreground,
                  filled: filledIcon,
                ),
                const SizedBox(width: space2),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: text.bodyStrong.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    if (style.material) return _materialButton(context, style.scheme!, text);
    return Pressable(
      onPressed: onPressed,
      radius: radiusPill,
      semanticLabel: label,
      builder: (context, state) {
        final Color foreground;
        Color background = Colors.transparent;
        Color border = Colors.transparent;
        if (!state.enabled) {
          foreground = colors.inkDisabled;
          if (kind == ButtonKind.primary) background = colors.line;
          if (kind == ButtonKind.secondary) border = colors.line;
        } else {
          switch (kind) {
            case ButtonKind.primary:
              foreground = colors.ground;
              background = state.hovered ? colors.inkMuted : colors.ink;
            case ButtonKind.secondary:
              foreground = colors.ink;
              border = colors.lineStrong;
              if (state.hovered) background = colors.surfaceHigh;
            case ButtonKind.text:
              foreground = colors.ink;
              if (state.hovered) background = colors.surfaceHigh;
          }
        }
        return Container(
          constraints: const BoxConstraints(
            minHeight: targetMin,
            minWidth: targetMin,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kind == ButtonKind.text ? space4 : space5,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadiusPill,
            border: Border.all(color: border, width: borderWidth),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AltynemelIcon(icon!, color: foreground, filled: filledIcon),
                const SizedBox(width: space2),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: text.bodyStrong.copyWith(
                    color: foreground,
                    decoration: kind == ButtonKind.text
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: foreground,
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
