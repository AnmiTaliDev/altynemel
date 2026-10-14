import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.sidebar,
    required this.body,
    required this.playerBar,
    this.titleBar,
  });

  final Widget sidebar;
  final Widget body;
  final Widget playerBar;
  final Widget? titleBar;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AltynemelColors.of(context).ground,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: sidebarWidth, child: sidebar),
                Expanded(
                  child: Column(
                    children: [
                      ?titleBar,
                      Expanded(child: body),
                    ],
                  ),
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
