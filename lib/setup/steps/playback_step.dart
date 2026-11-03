import 'package:flutter/material.dart';

import '../../components/choice_row.dart';
import '../../components/pill_tabs.dart';
import '../../components/setting_rows.dart';
import '../../components/toggle.dart';
import '../../settings/app_settings.dart';
import '../../settings/catalog.dart';
import '../../settings/choices.dart';
import '../../strings.dart';

class PlaybackStep extends StatelessWidget {
  const PlaybackStep({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Toggle(
              title: Strings.gapless,
              description: Strings.gaplessHint,
              value: settings.gapless,
              onChanged: settings.setGapless,
            ),
            Toggle(
              title: Strings.crossfade,
              description: Strings.crossfadeHint,
              value: settings.crossfade,
              onChanged: settings.setCrossfade,
            ),
            if (settings.crossfade)
              SettingSliderRow(
                title: crossfadeSeconds.label,
                valueText: crossfadeSeconds.describe(
                  settings.valueOf(crossfadeSeconds),
                ),
                value: settings.valueOf(crossfadeSeconds).toDouble(),
                min: crossfadeSeconds.min.toDouble(),
                max: crossfadeSeconds.max.toDouble(),
                step: 1,
                onChanged: (value) =>
                    settings.setValue(crossfadeSeconds, value.round()),
              ),
            ChoiceRow<ReplayGainMode>(
              title: Strings.setupNormalization,
              description: Strings.setupNormalizationHint,
              selected: settings.valueOf(replayGain),
              onSelected: (value) => settings.setValue(replayGain, value),
              options: [
                for (final mode in ReplayGainMode.values)
                  PillOption(value: mode, label: replayGainLabels[mode]!),
              ],
            ),
            ChoiceRow<int>(
              title: Strings.volumeStep,
              description: Strings.volumeStepHint,
              selected: settings.volumeStep,
              onSelected: settings.setVolumeStep,
              options: [
                for (final step in const [1, 5, 10])
                  PillOption(value: step, label: '$step'),
              ],
            ),
            Toggle(
              title: Strings.setupResume,
              description: Strings.setupResumeHint,
              value: settings.valueOf(resumeOnLaunch),
              onChanged: (value) => settings.setValue(resumeOnLaunch, value),
            ),
          ],
        );
      },
    );
  }
}
