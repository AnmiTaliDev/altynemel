import 'package:flutter/widgets.dart';

import '../theme/colors.dart';

class FocusRing extends StatelessWidget {
  const FocusRing({
    super.key,
    required this.visible,
    required this.radius,
    required this.child,
  });

  final bool visible;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned(
          left: -4,
          top: -4,
          right: -4,
          bottom: -4,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AltynemelColors.of(context).accent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(radius + 4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
