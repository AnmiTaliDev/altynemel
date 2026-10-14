import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/track_row.dart';

import '../support/pump.dart';

void main() {
  testWidgets('row reads as one phrase including state', (tester) async {
    await pumpThemed(
      tester,
      TrackRow(
        title: 'fading memories',
        artist: 'june lu, sløwmind',
        duration: const Duration(minutes: 2, seconds: 27),
        isPlaying: true,
        onPressed: () {},
        onMore: () {},
      ),
    );
    expect(
      find.bySemanticsLabel(
        'fading memories, june lu, sløwmind, 2 minutes 27 seconds, Playing now',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('More about fading memories'), findsOneWidget);
  });

  testWidgets('unavailable row shows the word and ignores taps', (
    tester,
  ) async {
    var taps = 0;
    await pumpThemed(
      tester,
      TrackRow(
        title: 'Балбырауын',
        artist: 'Құрманғазы',
        duration: const Duration(minutes: 4, seconds: 12),
        availability: TrackAvailability.unavailableOffline,
        onPressed: () => taps++,
        onMore: () {},
      ),
    );
    expect(find.text('Unavailable offline'), findsOneWidget);
    await tester.tap(find.text('Балбырауын'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('long title wraps at 200 percent and row grows', (tester) async {
    await pumpThemed(
      tester,
      SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: TrackRow(
            title:
                'A very long track title that must wrap instead of being cut off',
            artist: 'An artist with a long name',
            album: 'An album',
            duration: const Duration(minutes: 4, seconds: 12),
            onPressed: () {},
            onMore: () {},
          ),
        ),
      ),
      textScale: 2,
      size: const Size(360, 700),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(TrackRow)).height, greaterThan(64));
  });

  testWidgets('row is at least 64 px high', (tester) async {
    await pumpThemed(
      tester,
      TrackRow(
        title: 'a',
        artist: 'b',
        duration: const Duration(seconds: 5),
        onPressed: () {},
        onMore: () {},
      ),
    );
    expect(
      tester.getSize(find.byType(TrackRow)).height,
      greaterThanOrEqualTo(64),
    );
  });
}
