import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
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
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.mainNavigation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: space2),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.surfaceEdge, width: borderWidth),
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

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
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
