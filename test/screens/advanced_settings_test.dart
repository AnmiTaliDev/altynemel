import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    await tester.enterText(find.byType(TextField).last, 'mp3, flac');
    await tester.pump();
    expect(settings.valueOf(textDef), 'mp3, flac');
  });

  testWidgets('search narrows the rows and shows an empty state', (
    tester,
  ) async {
    await pumpAdvanced(tester);
    await tester.enterText(find.byType(TextField).first, 'speed');
    await tester.pump();
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Fade length'), findsNothing);
    expect(find.text('Playback'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'nothing here');
    await tester.pump();
    expect(find.text('No settings match'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('Fade length'), findsOneWidget);
  });

  testWidgets('a changed value gets a reset button that restores it', (
    tester,
  ) async {
    final settings = await pumpAdvanced(tester);
    expect(find.text('Reset'), findsNothing);
    await tester.tap(find.text('Loud'));
    await tester.pump();
    expect(find.text('Reset'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(settings.valueOf(enumDef), Mode.quiet);
    expect(find.text('Reset'), findsNothing);
  });

  testWidgets('reset all asks first and then restores every value', (
    tester,
  ) async {
    final settings = await pumpAdvanced(tester);
    await tester.tap(find.text('Loud'));
    await tester.tap(find.byType(Toggle));
    await tester.pump();
    expect(settings.valueOf(enumDef), Mode.loud);
    await tester.tap(find.text('Reset all'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all advanced settings?'), findsOneWidget);
    await tester.tap(find.text('Reset all').last);
    await tester.pumpAndSettle();
    expect(settings.valueOf(enumDef), Mode.quiet);
    expect(settings.valueOf(boolDef), isTrue);
  });

  testWidgets('reset all is disabled while nothing is changed', (tester) async {
    await pumpAdvanced(tester);
    await tester.tap(find.text('Reset all'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all advanced settings?'), findsNothing);
  });

  testWidgets('copy puts the changed values on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final settings = await pumpAdvanced(tester);
    settings.setValue(enumDef, Mode.loud);
    await tester.pump();
    await tester.tap(find.text('Copy settings'));
    await tester.pump();
    expect(copied, contains('"mode": "loud"'));
    expect(find.text('Copied to the clipboard.'), findsOneWidget);
  });

  testWidgets('paste applies settings from the clipboard', (tester) async {
    var clipboard = '{"version": 1, "values": {"mode": "loud"}}';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') return {'text': clipboard};
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final settings = await pumpAdvanced(tester);
    await tester.tap(find.text('Paste settings'));
    await tester.pump();
    expect(settings.valueOf(enumDef), Mode.loud);
    expect(find.text('Settings applied.'), findsOneWidget);
    clipboard = 'garbage';
    await tester.tap(find.text('Paste settings'));
    await tester.pump();
    expect(find.text('The clipboard has no valid settings.'), findsOneWidget);
    expect(settings.valueOf(enumDef), Mode.loud);
  });
}
