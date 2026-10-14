import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'pill_tabs.dart';

class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.description,
  });

  final String title;
  final String? description;
  final List<PillOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(vertical: space3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.line, width: borderWidth),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.bodyStrong),
          if (description != null)
            Text(
              description!,
              style: text.caption.copyWith(color: colors.inkMuted),
            ),
          const SizedBox(height: space3),
          PillTabs<T>(
            options: options,
            selected: selected,
            onSelected: onSelected,
            semanticLabel: title,
          ),
        ],
      ),
    );
  }
}
