import 'package:flutter/material.dart';

import '../components/menu.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: Strings.closeMenu,
    barrierColor: const Color(0x66000000),
    transitionDuration: Duration.zero,
    pageBuilder: (dialogContext, _, _) => Material(
      type: MaterialType.transparency,
      child: Center(
        child: MenuPanel(
          semanticLabel: title,
          title: title,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(space3, 0, space3, space3),
              child: Text(
                hint,
                style: AltynemelTextStyles.of(dialogContext).caption.copyWith(
                  color: AltynemelColors.of(dialogContext).inkMuted,
                ),
              ),
            ),
            MenuItem(
              label: confirmLabel,
              autofocus: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
            MenuItem(
              label: Strings.cancel,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
