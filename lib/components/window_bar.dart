import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../strings.dart';
import '../theme/spacing.dart';
import 'icon_button.dart';
import 'icon_data.dart';

class WindowBar extends StatelessWidget {
  const WindowBar({
    super.key,
    required this.maximized,
    required this.onMinimize,
    required this.onToggleMaximize,
    required this.onClose,
  });

  final bool maximized;
  final VoidCallback onMinimize;
  final VoidCallback onToggleMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: targetPointer,
      child: Row(
        children: [
          const Expanded(
            child: DragToMoveArea(
              child: SizedBox(height: targetPointer, width: double.infinity),
            ),
          ),
          AltynemelIconButton(
            icon: IconId.minimize,
            label: Strings.minimize,
            compact: true,
            onPressed: onMinimize,
          ),
          AltynemelIconButton(
            icon: maximized ? IconId.restore : IconId.maximize,
            label: maximized ? Strings.restore : Strings.maximize,
            compact: true,
            onPressed: onToggleMaximize,
          ),
          AltynemelIconButton(
            icon: IconId.close,
            label: Strings.closeWindow,
            compact: true,
            onPressed: onClose,
          ),
          const SizedBox(width: space2),
        ],
      ),
    );
  }
}
