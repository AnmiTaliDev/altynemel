import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';

enum PhoneTab { library, playlists, queue, settings }

class PhoneNav extends StatelessWidget {
  const PhoneNav({super.key, required this.selected, required this.onSelected});

  final PhoneTab? selected;
  final ValueChanged<PhoneTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final style = AltynemelStyle.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.mainNavigation,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          space2,
          0,
          space2,
          MediaQuery.viewPaddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: style.material
              ? style.scheme!.surfaceContainer
              : colors.surface,
          border: style.material
              ? null
              : Border(
                  top: BorderSide(
                    color: colors.surfaceEdge,
                    width: borderWidth,
                  ),
                ),
        ),
        child: Row(
          children: [
            _PhoneNavItem(
              icon: IconId.library,
              label: Strings.library,
              current: selected == PhoneTab.library,
              onPressed: () => onSelected(PhoneTab.library),
            ),
            _PhoneNavItem(
              icon: IconId.playlists,
              label: Strings.playlists,
              current: selected == PhoneTab.playlists,
              onPressed: () => onSelected(PhoneTab.playlists),
            ),
            _PhoneNavItem(
              icon: IconId.queue,
              label: Strings.queue,
              current: selected == PhoneTab.queue,
              onPressed: () => onSelected(PhoneTab.queue),
            ),
            _PhoneNavItem(
              icon: IconId.settings,
              label: Strings.settings,
              current: selected == PhoneTab.settings,
              onPressed: () => onSelected(PhoneTab.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNavItem extends StatelessWidget {
  const _PhoneNavItem({
    required this.icon,
    required this.label,
    required this.current,
    required this.onPressed,
  });

  final IconId icon;
  final String label;
  final bool current;
  final VoidCallback onPressed;

  Widget _materialItem(
    BuildContext context,
    ColorScheme scheme,
    AltynemelTextStyles text,
  ) {
    return Expanded(
      child: Pressable(
        onPressed: onPressed,
        radius: radiusControl,
        semanticLabel: label,
        selected: current,
        builder: (context, state) {
          final foreground = current
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant;
          final base = current ? scheme.secondaryContainer : Colors.transparent;
          final layer = state.pressed
              ? 0.12
              : (state.hovered || state.focused)
              ? 0.08
              : 0.0;
          return Container(
            height: 80,
            padding: const EdgeInsets.only(top: space3, bottom: space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: layer == 0
                        ? base
                        : Color.alphaBlend(
                            foreground.withValues(alpha: layer),
                            base,
                          ),
                    borderRadius: borderRadiusPill,
                  ),
                  child: AltynemelIcon(icon, size: 24, color: foreground),
                ),
                const SizedBox(height: space1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.label.copyWith(
                    color: current ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    if (style.material) return _materialItem(context, style.scheme!, text);
    final color = current ? colors.ink : colors.inkMuted;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: space1),
        child: Pressable(
          onPressed: onPressed,
          radius: radiusControl,
          semanticLabel: label,
          selected: current,
          builder: (context, state) {
            return Container(
              constraints: const BoxConstraints(minHeight: targetMin),
              padding: const EdgeInsets.symmetric(vertical: space1),
              decoration: BoxDecoration(
                color: current || state.hovered
                    ? colors.surfaceHigh
                    : Colors.transparent,
                borderRadius: borderRadiusControl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AltynemelIcon(icon, size: 22, color: color),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.caption.copyWith(color: color),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
