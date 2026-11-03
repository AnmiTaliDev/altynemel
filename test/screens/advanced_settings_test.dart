import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/progress_bar.dart';
import 'package:altynemel/components/toggle.dart';
import 'package:altynemel/screens/advanced_settings_screen.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/setting_def.dart';

import '../support/pump.dart';

enum Mode { quiet, loud }

const intDef = IntSetting(
  key: 'fade',
  group: SettingGroup.playback,
  label: 'Fade length',
  hint: 'Seconds of overlap.',
  defaultValue: 4,
  min: 1,
  max: 11,
  unit: 's',
);

const doubleDef = DoubleSetting(
  key: 'speed',
  group: SettingGroup.sound,
  label: 'Speed',
  hint: 'Playback speed.',
  defaultValue: 1,
  min: 0.5,
  max: 2,
  unit: 'x',
);

const boolDef = BoolSetting(
  key: 'hidden',
  group: SettingGroup.library,
  label: 'Skip hidden',
  hint: 'Ignore dot folders.',
  defaultValue: true,
);

const enumDef = EnumSetting<Mode>(
  key: 'mode',
  group: SettingGroup.appearance,
  label: 'Mode',
  hint: 'Loudness mode.',
  defaultValue: Mode.quiet,
  values: Mode.values,
  labels: {Mode.quiet: 'Quiet', Mode.loud: 'Loud'},
);

const textDef = TextSetting(
  key: 'ext',
  group: SettingGroup.search,
  label: 'Extensions',
  hint: 'Comma separated.',
  defaultValue: 'mp3',
);

const defs = <SettingDef<Object>>[intDef, doubleDef, boolDef, enumDef, textDef];

Future<AppSettings> pumpAdvanced(
  WidgetTester tester, {
  VoidCallback? onBack,
}) async {
  final settings = AppSettings();
  addTearDown(settings.dispose);
  await pumpThemed(
    tester,
    AdvancedSettingsScreen(
      settings: settings,
      onBack: onBack ?? () {},
      definitions: defs,
    ),
    size: const Size(800, 2400),
  );
  return settings;
}

void main() {
  testWidgets('every group gets a header and every definition a row', (
    tester,
  ) async {
    await pumpAdvanced(tester);
    for (final group in [
      'Playback',
      'Sound',
      'Appearance',
      'Library',
      'Search',
    ]) {
      expect(find.text(group), findsOneWidget);
    }
    for (final label in [
      'Fade length',
      'Speed',
      'Skip hidden',
      'Mode',
      'Extensions',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('4 s'), findsOneWidget);
    expect(find.text('1.0 x'), findsOneWidget);
  });

  testWidgets('the back button calls back', (tester) async {
    var back = 0;
    await pumpAdvanced(tester, onBack: () => back++);
    await tester.tap(find.text('Back'));
    expect(back, 1);
  });

  testWidgets('a toggle changes a bool setting', (tester) async {
    final settings = await pumpAdvanced(tester);
    await tester.tap(find.byType(Toggle));
    await tester.pump();
    expect(settings.valueOf(boolDef), isFalse);
  });

  testWidgets('a choice changes an enum setting', (tester) async {
    final settings = await pumpAdvanced(tester);
    await tester.tap(find.text('Loud'));
    await tester.pump();
    expect(settings.valueOf(enumDef), Mode.loud);
  });

  testWidgets('a slider tap changes an int setting', (tester) async {
    final settings = await pumpAdvanced(tester);
    final bar = tester.getRect(find.byType(ProgressBar).first);
    await tester.tapAt(Offset(bar.left + bar.width * 0.9, bar.center.dy));
    await tester.pump();
    expect(settings.valueOf(intDef), greaterThan(8));
  });

  testWidgets('typing changes a text setting', (tester) async {
    final settings = await pumpAdvanced(tester);
    await tester.enterText(find.byType(TextField), 'mp3, flac');
    await tester.pump();
    expect(settings.valueOf(textDef), 'mp3, flac');
  });
}
