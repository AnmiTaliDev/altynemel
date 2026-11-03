import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/choice_row.dart';
import '../components/layout_mode.dart';
import '../components/pill_tabs.dart';
import '../components/screen_header.dart';
import '../components/setting_rows.dart';
import '../components/toggle.dart';
import '../settings/app_settings.dart';
import '../settings/catalog.dart';
import '../settings/setting_def.dart';
import '../settings/setting_search.dart';
import '../strings.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({
    super.key,
    required this.settings,
    required this.onBack,
    this.definitions = allSettings,
  });

  final AppSettings settings;
  final VoidCallback onBack;
  final List<SettingDef<Object>> definitions;

  Widget _row(SettingDef<Object> def) {
    return switch (def) {
      IntSetting() => SettingSliderRow(
        title: def.label,
        description: def.hint,
        valueText: def.describe(settings.valueOf(def)),
        value: settings.valueOf(def).toDouble(),
        min: def.min.toDouble(),
        max: def.max.toDouble(),
        step: def.step.toDouble(),
        onChanged: (value) => settings.setValue(def, value.round()),
      ),
      DoubleSetting() => SettingSliderRow(
        title: def.label,
        description: def.hint,
        valueText: def.describe(settings.valueOf(def)),
        value: settings.valueOf(def),
        min: def.min,
        max: def.max,
        step: def.step,
        onChanged: (value) => settings.setValue(def, value),
      ),
      BoolSetting() => Toggle(
        title: def.label,
        description: def.hint,
        value: settings.valueOf(def),
        onChanged: (value) => settings.setValue(def, value),
      ),
      EnumSetting<Enum>() => ChoiceRow<Enum>(
        title: def.label,
        description: def.hint,
        selected: settings.valueOf<Enum>(def),
        onSelected: (value) => settings.setValue<Enum>(def, value),
        options: [
          for (final value in def.values)
            PillOption<Enum>(
              value: value,
              label: def.labels[value] ?? value.name,
            ),
        ],
      ),
      TextSetting() => SettingTextRow(
        title: def.label,
        description: def.hint,
        value: settings.valueOf(def),
        onChanged: (value) => settings.setValue(def, value),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final text = AltynemelTextStyles.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final groups = groupDefinitions(definitions);
        return ListView(
          padding: EdgeInsets.fromLTRB(
            pageGutter(context),
            space5,
            pageGutter(context),
            pageGutter(context),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AltynemelButton(
                label: Strings.back,
                kind: ButtonKind.text,
                onPressed: onBack,
              ),
            ),
            const SizedBox(height: space3),
            const ScreenHeader(
              title: Strings.advancedSettings,
              caption: Strings.advancedSettingsHint,
            ),
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: space6, bottom: space2),
                child: Semantics(
                  header: true,
                  child: Text(entry.key.title, style: text.displayMd),
                ),
              ),
              for (final def in entry.value) _row(def),
            ],
          ],
        );
      },
    );
  }
}
