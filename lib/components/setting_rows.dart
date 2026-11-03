import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'button.dart';
import 'progress_bar.dart';

class ResettableRow extends StatelessWidget {
  const ResettableRow({
    super.key,
    required this.title,
    required this.modified,
    required this.onReset,
    required this.child,
  });

  final String title;
  final bool modified;
  final VoidCallback onReset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        if (modified)
          Padding(
            padding: const EdgeInsets.only(top: space3, left: space2),
            child: Semantics(
              label: Strings.resetSettingLabel(title),
              excludeSemantics: true,
              child: AltynemelButton(
                label: Strings.resetSetting,
                kind: ButtonKind.text,
                onPressed: onReset,
              ),
            ),
          ),
      ],
    );
  }
}

class SettingSliderRow extends StatelessWidget {
  const SettingSliderRow({
    super.key,
    required this.title,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.description,
  });

  final String title;
  final String? description;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

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
          Row(
            children: [
              Expanded(child: Text(title, style: text.bodyStrong)),
              Text(valueText, style: text.time.copyWith(color: colors.ink)),
            ],
          ),
          if (description != null)
            Text(
              description!,
              style: text.caption.copyWith(color: colors.inkMuted),
            ),
          ProgressBar(
            value: value - min,
            max: max - min,
            step: step,
            semanticLabel: title,
            semanticValueOf: (offset) => valueText,
            onChanged: (offset) => onChanged(min + offset),
          ),
        ],
      ),
    );
  }
}

class SettingTextRow extends StatefulWidget {
  const SettingTextRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final String title;
  final String? description;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<SettingTextRow> createState() => _SettingTextRowState();
}

class _SettingTextRowState extends State<SettingTextRow> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(SettingTextRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text.trim()) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          Text(widget.title, style: text.bodyStrong),
          if (widget.description != null)
            Text(
              widget.description!,
              style: text.caption.copyWith(color: colors.inkMuted),
            ),
          const SizedBox(height: space2),
          Semantics(
            textField: true,
            label: widget.title,
            child: Container(
              constraints: const BoxConstraints(minHeight: targetPointer),
              padding: const EdgeInsets.symmetric(horizontal: space3),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: borderRadiusControl,
                border: Border.all(
                  color: colors.lineStrong,
                  width: borderWidth,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: text.body,
                cursorColor: colors.ink,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
