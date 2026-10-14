import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/transport.dart';
import 'package:altynemel/player/repeat_setting.dart';

import '../support/pump.dart';

Widget _transport({
  required bool isPlaying,
  RepeatSetting repeat = RepeatSetting.off,
  TransportVariant variant = TransportVariant.accent,
  VoidCallback? onPlayPause,
}) {
  return Center(
    child: SizedBox(
      width: 400,
      child: Transport(
        variant: variant,
        isPlaying: isPlaying,
        shuffle: false,
        repeat: repeat,
        onShuffle: () {},
        onPrevious: () {},
        onPlayPause: onPlayPause ?? () {},
        onNext: () {},
        onRepeat: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('play button label follows state', (tester) async {
    await pumpThemed(tester, _transport(isPlaying: false));
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.bySemanticsLabel('Pause'), findsNothing);
    await pumpThemed(tester, _transport(isPlaying: true));
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
  });

  testWidgets('all five buttons are labelled', (tester) async {
    await pumpThemed(tester, _transport(isPlaying: false));
    for (final label in [
      'Shuffle',
      'Previous track',
      'Play',
      'Next track',
      'Repeat',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('repeat label names the mode', (tester) async {
    await pumpThemed(
      tester,
      _transport(isPlaying: false, repeat: RepeatSetting.one),
    );
    expect(find.bySemanticsLabel('Repeat one'), findsOneWidget);
  });

  testWidgets('accent play button is 72 px, bar variant is 48 px', (
    tester,
  ) async {
    await pumpThemed(tester, _transport(isPlaying: false));
    expect(tester.getSize(find.bySemanticsLabel('Play')), const Size(72, 72));
    await pumpThemed(
      tester,
      _transport(isPlaying: false, variant: TransportVariant.bar),
    );
    expect(tester.getSize(find.bySemanticsLabel('Play')), const Size(48, 48));
  });

  testWidgets('tapping play calls back', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      _transport(isPlaying: false, onPlayPause: () => taps++),
    );
    await tester.tap(find.bySemanticsLabel('Play'));
    expect(taps, 1);
  });

  testWidgets('repeat one shows a badge, repeat all does not', (tester) async {
    await pumpThemed(
      tester,
      _transport(isPlaying: false, repeat: RepeatSetting.one),
    );
    expect(find.text('1'), findsOneWidget);
    await pumpThemed(
      tester,
      _transport(isPlaying: false, repeat: RepeatSetting.all),
    );
    expect(find.text('1'), findsNothing);
  });
}
