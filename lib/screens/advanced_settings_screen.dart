import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/choice_row.dart';
import '../components/layout_mode.dart';
import '../components/pill_tabs.dart';
import '../components/screen_header.dart';
import '../components/search_field.dart';
import '../components/setting_rows.dart';
import '../components/toggle.dart';
import '../settings/app_settings.dart';
import '../settings/catalog.dart';
import '../settings/setting_def.dart';
import '../settings/setting_search.dart';
import '../strings.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'confirm_dialog.dart';
import 'empty_state.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({
    super.key,
    required this.settings,
    required this.onBack,
    this.definitions = allSettings,
  });

  final AppSettings settings;
  final VoidCallback onBack;
  final List<SettingDef<Object>> definitions;

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  String _query = '';

  AppSettings get settings => widget.settings;

  Future<void> _resetAll() async {
    final confirmed = await confirmAction(
      context,
      title: Strings.resetAllQuestion,
      hint: Strings.resetAllHint,
      confirmLabel: Strings.resetAllSettings,
    );
    if (!confirmed || !mounted) return;
    settings.resetAll(widget.definitions);
  }

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
        final matches = searchDefinitions(widget.definitions, _query);
        final groups = groupDefinitions(matches);
        return ListView(
          padding: EdgeInsets.fromLTRB(
            pageGutter(context),
            space5,
            pageGutter(context),
            pageGutter(context),
          ),
          children: [
            Row(
              children: [
                AltynemelButton(
                  label: Strings.back,
                  kind: ButtonKind.text,
                  onPressed: widget.onBack,
                ),
                const Spacer(),
                AltynemelButton(
                  label: Strings.resetAllSettings,
                  kind: ButtonKind.text,
                  onPressed: widget.definitions.any(settings.isModified)
                      ? _resetAll
                      : null,
                ),
              ],
            ),
            const SizedBox(height: space3),
            const ScreenHeader(
              title: Strings.advancedSettings,
              caption: Strings.advancedSettingsHint,
            ),
            const SizedBox(height: space4),
            SearchField(
              label: Strings.searchSettings,
              onChanged: (value) => setState(() => _query = value),
            ),
            if (matches.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: space5),
                child: EmptyState(
                  title: Strings.noSettingsFound,
                  hint: Strings.noSettingsFoundHint,
                ),
              ),
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: space6, bottom: space2),
                child: Semantics(
                  header: true,
                  child: Text(entry.key.title, style: text.displayMd),
                ),
              ),
              for (final def in entry.value)
                ResettableRow(
                  title: def.label,
                  modified: settings.isModified(def),
                  onReset: () => settings.reset(def),
                  child: _row(def),
                ),
            ],
          ],
        );
      },
    );
  }
}
