import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/mini_player.dart';
import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/player/repeat_setting.dart';
import 'package:altynemel/theme/colors.dart';

import '../support/pump.dart';

PlayerBar bar({String? error}) => PlayerBar(
  title: 'DES',
  artist: 'Katarsis',
  error: error,
  liked: false,
  onToggleLike: () {},
  isPlaying: false,
  shuffle: false,
  repeat: RepeatSetting.off,
  onShuffle: () {},
  onPrevious: () {},
  onPlayPause: () {},
  onNext: () {},
  onRepeat: () {},
  position: Duration.zero,
  duration: const Duration(minutes: 3),
  onSeek: (_) {},
  volume: 50,
  onVolume: (_) {},
  onQueue: () {},
);

void main() {
  testWidgets('the player bar shows the artist when there is no error', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      Align(alignment: Alignment.bottomCenter, child: bar()),
    );
    expect(find.text('Katarsis'), findsOneWidget);
  });

  testWidgets('the player bar shows the error instead of the artist', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: bar(error: 'File not found: DES'),
      ),
    );
    expect(find.text('File not found: DES'), findsOneWidget);
    expect(find.text('Katarsis'), findsNothing);
    final color = tester
        .widget<Text>(find.text('File not found: DES'))
        .style!
        .color;
    expect(color, AltynemelColors.night.alert);
  });

  testWidgets('the compact bar shows the error too', (tester) async {
    await pumpThemed(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: bar(error: 'File not found: DES'),
      ),
      size: const Size(500, 600),
    );
    expect(find.text('File not found: DES'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the mini player shows the error instead of the artist', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      MiniPlayer(
        title: 'DES',
        artist: 'Katarsis',
        error: 'File not found: DES',
        isPlaying: false,
        progress: 0,
        onOpen: () {},
        onPlayPause: () {},
      ),
      size: const Size(400, 200),
    );
    expect(find.text('File not found: DES'), findsOneWidget);
    expect(find.text('Katarsis'), findsNothing);
  });

  testWidgets('the mini player keeps the artist without an error', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      MiniPlayer(
        title: 'DES',
        artist: 'Katarsis',
        isPlaying: false,
        progress: 0,
        onOpen: () {},
        onPlayPause: () {},
      ),
      size: const Size(400, 200),
    );
    expect(find.text('Katarsis'), findsOneWidget);
  });
}
