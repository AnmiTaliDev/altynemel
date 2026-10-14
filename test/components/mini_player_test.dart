import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/cover_art.dart';
import 'package:altynemel/components/mini_player.dart';

import '../support/pump.dart';

void main() {
  testWidgets('card and pause button have separate labels and targets', (
    tester,
  ) async {
    var opened = 0;
    var toggled = 0;
    await pumpThemed(
      tester,
      Padding(
        padding: const EdgeInsets.all(8),
        child: MiniPlayer(
          title: 'fading memories',
          artist: 'june lu, sløwmind',
          isPlaying: true,
          progress: 0.33,
          onOpen: () => opened++,
          onPlayPause: () => toggled++,
        ),
      ),
      size: const Size(400, 200),
    );
    expect(
      find.bySemanticsLabel('Now playing: fading memories, june lu, sløwmind'),
      findsOneWidget,
    );
    expect(tester.getSize(find.bySemanticsLabel('Pause')), const Size(48, 48));
    await tester.tap(find.bySemanticsLabel('Pause'));
    expect(toggled, 1);
    expect(opened, 0);
    await tester.tapAt(const Offset(80, 40));
    expect(opened, 1);
  });

  testWidgets('cover without image is labelled as unavailable', (tester) async {
    await pumpThemed(tester, const Center(child: CoverArt(size: 160)));
    expect(find.bySemanticsLabel('Cover art unavailable'), findsOneWidget);
    expect(tester.getSize(find.byType(CoverArt)), const Size(160, 160));
  });

  testWidgets('arch cover has 4:5 proportions', (tester) async {
    await pumpThemed(
      tester,
      const Center(child: CoverArt(size: 200, shape: CoverShape.arch)),
    );
    expect(tester.getSize(find.byType(CoverArt)), const Size(200, 250));
  });
}
