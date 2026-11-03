import 'package:flutter/material.dart';

import '../components/icon.dart';
import '../components/icon_data.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'setup_step.dart';

class SetupStepper extends StatelessWidget {
  const SetupStepper({super.key, required this.current});

  final SetupStep current;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final steps = SetupStep.values;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.setupStepsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in steps)
            Semantics(
              label:
                  '${Strings.setupStepOf(step.index + 1, steps.length)}, ${step.label}',
              selected: step == current,
              excludeSemantics: true,
              child: _StepRow(
                step: step,
                state: step.index < current.index
                    ? _StepState.done
                    : step == current
                    ? _StepState.current
                    : _StepState.upcoming,
                last: step == steps.last,
                colors: colors,
                text: text,
              ),
            ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.state,
    required this.last,
    required this.colors,
    required this.text,
  });

  final SetupStep step;
  final _StepState state;
  final bool last;
  final AltynemelColors colors;
  final AltynemelTextStyles text;

  @override
  Widget build(BuildContext context) {
    final filled = state != _StepState.upcoming;
    final duration = motionDuration(context, motionQuick);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: duration,
                  curve: motionCurve,
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: filled ? colors.accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: filled ? colors.accent : colors.lineStrong,
                      width: borderWidth,
                    ),
                  ),
                  child: state == _StepState.done
                      ? AltynemelIcon(
                          IconId.check,
                          size: 18,
                          color: colors.onAccent,
                          strokeWidth: 2.2,
                        )
                      : Text(
                          '${step.index + 1}',
                          style: text.label.copyWith(
                            color: filled ? colors.onAccent : colors.inkMuted,
                          ),
                        ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: space1),
                      color: state == _StepState.done
                          ? colors.accent
                          : colors.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: space3),
          Padding(
            padding: const EdgeInsets.only(top: space1, bottom: space5),
            child: Text(
              step.label,
              style: state == _StepState.current
                  ? text.bodyStrong
                  : text.body.copyWith(color: colors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class SetupSegments extends StatelessWidget {
  const SetupSegments({super.key, required this.current});

  final SetupStep current;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final total = SetupStep.values.length;
    final duration = motionDuration(context, motionQuick);
    return Semantics(
      container: true,
      label: Strings.setupStepsLabel,
      value:
          '${Strings.setupStepOf(current.index + 1, total)}, ${current.label}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: space1),
                Expanded(
                  child: AnimatedContainer(
                    duration: duration,
                    curve: motionCurve,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= current.index ? colors.accent : colors.line,
                      borderRadius: borderRadiusPill,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: space2),
          Text(
            '${Strings.setupStepOf(current.index + 1, total)}  ·  ${current.label}',
            style: text.caption.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
