import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';

import '../support/fonts.dart';
import '../support/test_library.dart';

const sizes = [Size(640, 480), Size(800, 600), Size(1100, 700)];
const scales = [1.3, 1.5];
const destinations = {
  'library': SidebarDestination.library,
  'queue': SidebarDestination.queue,
  'now playing list': SidebarDestination.nowPlaying,
  'settings': SidebarDestination.settings,
};

void main() {
  setUpAll(loadOnest);

  for (final scale in scales) {
    for (final size in sizes) {
      for (final entry in destinations.entries) {
        testWidgets(
          '${entry.key} at ${size.width.toInt()}x${size.height.toInt()} '
          'with $scale text scale has no layout errors',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final lib = TestLibrary();
            addTearDown(lib.dispose);
            await tester.pumpWidget(
              lib.wrap(HomeScreen(initialDestination: entry.value)),
            );
            await tester.pumpAndSettle();
            lib.playback.playTracks(lib.library.tracks, 1, title: 'Playing');
            await tester.pumpAndSettle();
            final applied = MediaQuery.textScalerOf(
              tester.element(find.byType(HomeScreen)),
            );
            expect(applied.scale(10), closeTo(10 * scale, 0.001));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('bar time labels stay on one line at 1.5 text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 480);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(lib.wrap(const HomeScreen()));
    lib.playback.playTracks(lib.library.tracks, 1, title: 'Playing');
    await tester.pumpAndSettle();
    final times = find.descendant(
      of: find.byType(PlayerBar),
      matching: find.text('0:00'),
    );
    expect(tester.getSize(times).height, lessThan(30));
  });
}
