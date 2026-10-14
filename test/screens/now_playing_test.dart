import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/screens/now_playing_screen.dart';
import 'package:altynemel/screens/queue_screen.dart';

import '../support/test_library.dart';
import 'home_playback_test.dart' show pumpHome, startPlaylist;

void main() {
  testWidgets('nothing opens while no track is loaded', (tester) async {
    await pumpHome(tester);
    expect(find.bySemanticsLabel('Open now playing'), findsNothing);
  });

  testWidgets('the player bar opens and collapses the full screen', (
    tester,
  ) async {
    await pumpHome(tester);
    await startPlaylist(tester);
    expect(find.byType(NowPlayingScreen), findsNothing);
    await tester.tap(find.bySemanticsLabel('Open now playing'));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsOneWidget);
    expect(find.text('fading memories'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Collapse'));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsNothing);
  });

  testWidgets('escape collapses and space still toggles playback', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await startPlaylist(tester);
    await tester.tap(find.bySemanticsLabel('Open now playing'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsNothing);
    await tester.tap(find.bySemanticsLabel('Open now playing'));
    await tester.pumpAndSettle();
    final was = lib.playback.isPlaying;
    await tester.tap(
      find.descendant(
        of: find.byType(NowPlayingScreen),
        matching: find.bySemanticsLabel(was ? 'Pause' : 'Play'),
      ),
    );
    await tester.pumpAndSettle();
    expect(lib.playback.isPlaying, !was);
  });

  testWidgets('the queue button leaves the full screen for the queue', (
    tester,
  ) async {
    await pumpHome(tester);
    await startPlaylist(tester);
    await tester.tap(find.bySemanticsLabel('Open now playing'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NowPlayingScreen),
        matching: find.bySemanticsLabel('Queue'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsNothing);
    expect(find.byType(QueueScreen), findsOneWidget);
  });

  testWidgets('a narrow window with 200 percent text has no layout errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(640, 480),
          textScaler: TextScaler.linear(2),
        ),
        child: lib.wrap(
          NowPlayingScreen(
            title: 'A very long title that has to wrap over several lines',
            artist: 'Artist',
            album: 'Album',
            liked: false,
            onToggleLike: () {},
            isPlaying: true,
            shuffle: false,
            repeat: lib.playback.repeat,
            onShuffle: () {},
            onPrevious: () {},
            onPlayPause: () {},
            onNext: () {},
            onRepeat: () {},
            position: const Duration(seconds: 30),
            duration: const Duration(minutes: 4),
            onSeek: (_) {},
            volume: 70,
            onVolume: (_) {},
            onQueue: () {},
            onCollapse: () {},
            onMore: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
