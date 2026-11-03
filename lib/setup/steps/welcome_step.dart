import 'package:flutter/material.dart';

import '../../components/icon.dart';
import '../../components/icon_data.dart';
import '../../strings.dart';
import '../../theme/colors.dart';
import '../../theme/radii.dart';
import '../../theme/spacing.dart';
import '../../theme/style.dart';
import '../../theme/text_styles.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Highlight(icon: IconId.settings, label: Strings.setupWelcomeLook),
        SizedBox(height: space3),
        _Highlight(icon: IconId.library, label: Strings.setupWelcomeMusic),
        SizedBox(height: space3),
        _Highlight(icon: IconId.play, label: Strings.setupWelcomePlayback),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({required this.icon, required this.label});

  final IconId icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    final badge = style.material
        ? style.scheme!.primaryContainer
        : colors.surfaceHigh;
    final glyph = style.material
        ? style.scheme!.onPrimaryContainer
        : colors.ink;
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(space3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: borderRadiusCard,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badge,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AltynemelIcon(
                icon,
                size: 24,
                color: glyph,
                filled: icon == IconId.play,
              ),
            ),
            const SizedBox(width: space4),
            Expanded(child: Text(label, style: text.bodyLg)),
          ],
        ),
      ),
    );
  }
}
