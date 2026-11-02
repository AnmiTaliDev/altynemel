import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

bool sidebarCompactFor(double windowWidth) => windowWidth < sidebarCompactBelow;

double sidebarSlotWidth(double windowWidth) =>
    sidebarCompactFor(windowWidth) ? sidebarRailWidth : sidebarWidth;

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.sidebar,
    required this.body,
    required this.playerBar,
    this.titleBar,
    this.expanded = false,
    this.onDismiss,
  });

  final Widget sidebar;
  final Widget body;
  final Widget playerBar;
  final Widget? titleBar;
  final bool expanded;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final windowWidth = MediaQuery.sizeOf(context).width;
    final compact = sidebarCompactFor(windowWidth);
    final slot = sidebarSlotWidth(windowWidth);
    final overlay = compact && expanded;
    return ColoredBox(
      color: colors.ground,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  left: slot,
                  child: Column(
                    children: [
                      ?titleBar,
                      Expanded(child: body),
                    ],
                  ),
                ),
                if (overlay)
                  Positioned.fill(
                    left: sidebarWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDismiss,
                      child: ColoredBox(
                        color: colors.ground.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: overlay ? sidebarWidth : slot,
                  child: ColoredBox(color: colors.ground, child: sidebar),
                ),
              ],
            ),
          ),
          playerBar,
        ],
      ),
    );
  }
}
