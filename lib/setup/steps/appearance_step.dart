import 'package:flutter/material.dart';

import '../../settings/app_settings.dart';
import '../../settings/catalog.dart';
import '../../settings/choices.dart';
import '../../strings.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../theme/themes.dart';
import '../../components/choice_row.dart';
import '../../components/pill_tabs.dart';
import 'accent_swatches.dart';
import 'style_card.dart';

class AppearanceStep extends StatelessWidget {
  const AppearanceStep({super.key, required this.settings});

  final AppSettings settings;

  Widget _label(BuildContext context, String title) {
    final text = AltynemelTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: space3),
      child: Semantics(
        header: true,
        child: Text(title, style: text.bodyStrong),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = MediaQuery.platformBrightnessOf(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final themeId = resolveThemeId(settings.theme, platform);
        final accent = settings.valueOf(accentColor);
        final current = settings.valueOf(designStyle);
        Widget card(DesignStyle design, String title, String hint) => StyleCard(
          design: design,
          title: title,
          hint: hint,
          selected: current == design,
          themeId: themeId,
          accent: accent,
          onSelected: () => settings.setValue(designStyle, design),
        );
        final cards = [
          card(
            DesignStyle.altynemel,
            Strings.setupStyleAltynemel,
            Strings.setupStyleAltynemelHint,
          ),
          card(
            DesignStyle.material,
            Strings.setupStyleMaterial,
            Strings.setupStyleMaterialHint,
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label(context, Strings.setupStyleLabel),
            Semantics(
              container: true,
              explicitChildNodes: true,
              label: Strings.setupStyleLabel,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 560) {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: space3),
                        cards[1],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: space3),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: space5),
            ChoiceRow<ThemeChoice>(
              title: Strings.setupThemeLabel,
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
            const SizedBox(height: space4),
            _label(context, Strings.setupAccentLabel),
            AccentSwatches(
              selected: accent,
              theme: themeId,
              design: current,
              onSelected: (choice) => settings.setValue(accentColor, choice),
            ),
          ],
        );
      },
    );
  }
}
