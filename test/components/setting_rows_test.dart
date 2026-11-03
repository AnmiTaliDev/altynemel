import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/progress_bar.dart';
import 'package:altynemel/components/setting_rows.dart';

import '../support/pump.dart';

void main() {
  testWidgets('slider row shows the value and reports taps as values', (
    tester,
  ) async {
    double? reported;
    await pumpThemed(
      tester,
      SettingSliderRow(
        title: 'Crossfade',
        valueText: '4 s',
        value: 6,
        min: 1,
        max: 11,
        step: 1,
        onChanged: (value) => reported = value,
      ),
      size: const Size(600, 300),
    );
    expect(find.text('Crossfade'), findsOneWidget);
    expect(find.text('4 s'), findsOneWidget);
    final bar = tester.getRect(find.byType(ProgressBar));
    await tester.tapAt(Offset(bar.left + bar.width * 0.75, bar.center.dy));
    await tester.pump();
    expect(reported, closeTo(8.5, 0.3));
  });

  testWidgets('the reset button appears only for changed values', (
    tester,
  ) async {
    var resets = 0;
    Widget row(bool modified) => ResettableRow(
      title: 'Seek',
      modified: modified,
      onReset: () => resets++,
      child: const SizedBox(height: 40),
    );
    await pumpThemed(tester, row(false), size: const Size(600, 300));
    expect(find.text('Reset'), findsNothing);
    await pumpThemed(tester, row(true), size: const Size(600, 300));
    expect(find.text('Reset'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    expect(resets, 1);
  });

  testWidgets('text row reports edits and follows outside changes', (
    tester,
  ) async {
    final edits = <String>[];
    Widget row(String value) =>
        SettingTextRow(title: 'Extensions', value: value, onChanged: edits.add);
    await pumpThemed(tester, row('mp3'), size: const Size(600, 300));
    await tester.enterText(find.byType(TextField), 'mp3, flac');
    expect(edits.last, 'mp3, flac');
    await pumpThemed(tester, row('ogg'), size: const Size(600, 300));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'ogg',
    );
  });
}
