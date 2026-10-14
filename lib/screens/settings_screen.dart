import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/choice_row.dart';
import '../components/pill_tabs.dart';
import '../components/screen_header.dart';
import '../components/toggle.dart';
import '../settings/app_settings.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    this.onChooseFolder,
    this.onOpenAbout,
  });

  final AppSettings settings;
  final VoidCallback? onChooseFolder;
  final VoidCallback? onOpenAbout;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: space6, bottom: space2),
      child: Semantics(header: true, child: Text(title, style: text.displayMd)),
    );
    final folder = settings.libraryFolder;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(space6, space5, space6, space6),
          children: [
            const ScreenHeader(title: Strings.settings),
            section(Strings.appearance),
            ChoiceRow<ThemeChoice>(
              title: Strings.theme,
              description: Strings.themeHint,
              selected: settings.theme,
              onSelected: settings.setTheme,
              options: const [
                PillOption(
                  value: ThemeChoice.system,
                  label: Strings.themeSystem,
                ),
                PillOption(value: ThemeChoice.night, label: Strings.themeNight),
                PillOption(value: ThemeChoice.day, label: Strings.themeDay),
                PillOption(
                  value: ThemeChoice.contrast,
                  label: Strings.themeContrast,
                ),
              ],
            ),
            Toggle(
              title: Strings.reduceMotion,
              description: Strings.reduceMotionHint,
              value: settings.reduceMotion,
              onChanged: settings.setReduceMotion,
            ),
            section(Strings.playback),
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
            ChoiceRow<int>(
              title: Strings.volumeStep,
              description: Strings.volumeStepHint,
              selected: settings.volumeStep,
              onSelected: settings.setVolumeStep,
              options: const [
                PillOption(value: 1, label: '1'),
                PillOption(value: 5, label: '5'),
                PillOption(value: 10, label: '10'),
              ],
            ),
            section(Strings.library),
            Container(
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
                  Text(Strings.libraryFolder, style: text.bodyStrong),
                  Text(
                    folder ?? Strings.libraryFolderNone,
                    style: text.caption.copyWith(color: colors.inkMuted),
                  ),
                  if (onChooseFolder == null)
                    Text(
                      Strings.unavailableInBuild,
                      style: text.caption.copyWith(color: colors.inkMuted),
                    ),
                  const SizedBox(height: space3),
                  AltynemelButton(
                    label: Strings.chooseFolder,
                    onPressed: onChooseFolder,
                  ),
                ],
              ),
            ),
            ChoiceRow<RescanInterval>(
              title: Strings.rescan,
              description: Strings.rescanHint,
              selected: settings.rescanInterval,
              onSelected: settings.setRescanInterval,
              options: const [
                PillOption(
                  value: RescanInterval.minutes5,
                  label: Strings.minutes5,
                ),
                PillOption(
                  value: RescanInterval.minutes15,
                  label: Strings.minutes15,
                ),
                PillOption(value: RescanInterval.hour1, label: Strings.hour1),
              ],
            ),
            Toggle(
              title: Strings.splitArtists,
              description: Strings.splitArtistsHint,
              value: settings.splitArtists,
              onChanged: settings.setSplitArtists,
            ),
            ChoiceRow<AlbumOrder>(
              title: Strings.albumOrder,
              description: Strings.albumOrderHint,
              selected: settings.albumOrder,
              onSelected: settings.setAlbumOrder,
              options: const [
                PillOption(
                  value: AlbumOrder.discAndTrack,
                  label: Strings.orderDiscTrack,
                ),
                PillOption(
                  value: AlbumOrder.fileName,
                  label: Strings.orderFileName,
                ),
              ],
            ),
            section(Strings.about),
            Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(vertical: space3),
              alignment: Alignment.centerLeft,
              child: AltynemelButton(
                label: Strings.aboutApp,
                onPressed: onOpenAbout,
              ),
            ),
          ],
        );
      },
    );
  }
}
