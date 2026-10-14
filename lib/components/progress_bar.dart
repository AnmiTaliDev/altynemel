import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'focus_ring.dart';

class _StepIntent extends Intent {
  const _StepIntent(this.direction);

  final int direction;
}

class ProgressBar extends StatefulWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    required this.semanticValueOf,
    this.step = 5,
    this.height = targetMin,
    this.gapColor,
  });

  final double value;
  final double max;
  final ValueChanged<double>? onChanged;
  final String semanticLabel;
  final String Function(double value) semanticValueOf;
  final double step;
  final double height;
  final Color? gapColor;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  bool _focused = false;

  void _change(double next) {
    widget.onChanged?.call(next.clamp(0, widget.max).toDouble());
  }

  void _setFromDx(double dx, double width) {
    if (width <= 0) return;
    _change(dx / width * widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final enabled = widget.onChanged != null && widget.max > 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = widget.max <= 0
            ? 0.0
            : (widget.value / widget.max).clamp(0.0, 1.0);
        final x = width * fraction;
        return Semantics(
          container: true,
          slider: true,
          enabled: enabled,
          label: widget.semanticLabel,
          value: widget.semanticValueOf(widget.value),
          increasedValue: widget.semanticValueOf(
            (widget.value + widget.step).clamp(0, widget.max).toDouble(),
          ),
          decreasedValue: widget.semanticValueOf(
            (widget.value - widget.step).clamp(0, widget.max).toDouble(),
          ),
          onIncrease: enabled
              ? () => _change(widget.value + widget.step)
              : null,
          onDecrease: enabled
              ? () => _change(widget.value - widget.step)
              : null,
          excludeSemantics: true,
          child: FocusableActionDetector(
            enabled: enabled,
            mouseCursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onShowFocusHighlight: (value) => setState(() => _focused = value),
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
              SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
              SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
              SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
            },
            actions: {
              _StepIntent: CallbackAction<_StepIntent>(
                onInvoke: (intent) {
                  _change(widget.value + intent.direction * widget.step);
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: enabled
                  ? (d) => _setFromDx(d.localPosition.dx, width)
                  : null,
              onHorizontalDragStart: enabled
                  ? (d) => _setFromDx(d.localPosition.dx, width)
                  : null,
              onHorizontalDragUpdate: enabled
                  ? (d) => _setFromDx(d.localPosition.dx, width)
                  : null,
              child: FocusRing(
                visible: _focused,
                radius: 8,
                child: SizedBox(
                  width: width,
                  height: widget.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: (widget.height - 4) / 2,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.line,
                            borderRadius: borderRadiusPill,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        width: x,
                        top: (widget.height - 4) / 2,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.ink,
                            borderRadius: borderRadiusPill,
                          ),
                        ),
                      ),
                      Positioned(
                        left: x - 11,
                        top: (widget.height - 22) / 2,
                        width: 22,
                        height: 22,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.ink,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.gapColor ?? colors.ground,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
