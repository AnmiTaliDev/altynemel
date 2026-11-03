import 'package:flutter/material.dart';

import '../../settings/app_settings.dart';
import '../../settings/catalog.dart';
import '../../settings/choices.dart';
import '../../strings.dart';
import '../../theme/colors.dart';
import '../../theme/radii.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';

String themeLabel(ThemeChoice choice) => switch (choice) {
  ThemeChoice.system => Strings.themeSystem,
  ThemeChoice.night => Strings.themeNight,
  ThemeChoice.day => Strings.themeDay,
  ThemeChoice.contrast => Strings.themeContrast,
};

String playbackSummary(AppSettings settings) {
  return [
    settings.gapless
        ? Strings.setupSummaryGaplessOn
        : Strings.setupSummaryGaplessOff,
    settings.crossfade
        ? Strings.setupSummaryCrossfade(settings.valueOf(crossfadeSeconds))
        : Strings.setupSummaryNoCrossfade,
    Strings.setupSummaryNormalization(
      replayGainLabels[settings.valueOf(replayGain)]!,
    ),
  ].join('  ·  ');
}

class FinishStep extends StatelessWidget {
  const FinishStep({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final folder = settings.libraryFolder;
        final rows = [
          (
            Strings.setupSummaryStyle,
            designStyleLabels[settings.valueOf(designStyle)]!,
          ),
          (Strings.setupSummaryTheme, themeLabel(settings.theme)),
          (
            Strings.setupSummaryAccent,
            accentLabels[settings.valueOf(accentColor)]!,
          ),
          (Strings.setupSummaryLibrary, folder ?? Strings.setupSummaryNoFolder),
          (Strings.setupSummaryPlayback, playbackSummary(settings)),
        ];
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: borderRadiusCard,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: space4,
            vertical: space2,
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.line),
                _SummaryRow(label: rows[i].$1, value: rows[i].$2),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Semantics(
      container: true,
      label: '$label, $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: space3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 420;
            final labelText = Text(
              label,
              style: text.body.copyWith(color: colors.inkMuted),
            );
            final valueText = Text(value, style: text.bodyStrong);
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelText,
                  const SizedBox(height: space1),
                  valueText,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 160, child: labelText),
                Expanded(child: valueText),
              ],
            );
          },
        ),
      ),
    );
  }
}
