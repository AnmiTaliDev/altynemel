import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

class PhoneShell extends StatelessWidget {
  const PhoneShell({
    super.key,
    required this.body,
    required this.nav,
    this.titleBar,
    this.miniPlayer,
  });

  final Widget body;
  final Widget nav;
  final Widget? titleBar;
  final Widget? miniPlayer;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AltynemelColors.of(context).ground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ?titleBar,
            Expanded(child: body),
            if (miniPlayer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  space2,
                  space2,
                  space2,
                  space2,
                ),
                child: miniPlayer,
              ),
            nav,
          ],
        ),
      ),
    );
  }
}
