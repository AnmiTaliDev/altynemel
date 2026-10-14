import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.hint,
    this.action,
  });

  final String title;
  final String hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.displayMd),
        const SizedBox(height: space2),
        Text(hint, style: text.body.copyWith(color: colors.inkMuted)),
        if (action != null) ...[const SizedBox(height: space5), action!],
      ],
    );
  }
}
