import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.sidebar,
    required this.body,
    required this.playerBar,
  });

  final Widget sidebar;
  final Widget body;
  final Widget playerBar;

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
                Expanded(child: body),
              ],
            ),
          ),
          playerBar,
        ],
      ),
    );
  }
}
