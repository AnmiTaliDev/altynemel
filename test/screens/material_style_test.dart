import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/style.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/fonts.dart';
import '../support/test_library.dart';

const sizes = [Size(360, 720), Size(640, 480), Size(1100, 700)];
const scales = [1.0, 1.5];
const destinations = {
  'library': SidebarDestination.library,
  'playlists': SidebarDestination.playlists,
  'queue': SidebarDestination.queue,
  'settings': SidebarDestination.settings,
};

void main() {
  setUpAll(loadOnest);

  for (final theme in AltynemelThemeId.values) {
    for (final size in sizes) {
      for (final scale in scales) {
        for (final entry in destinations.entries) {
          testWidgets('${entry.key} in Material 3 ${theme.name} at '
              '${size.width.toInt()}x${size.height.toInt()}, scale $scale', (
            tester,
          ) async {
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
              lib.wrap(
                HomeScreen(initialDestination: entry.value),
                theme: theme,
                style: DesignStyle.material,
              ),
            );
            await tester.pumpAndSettle();
            expect(
              AltynemelStyle.of(
                tester.element(find.byType(HomeScreen)),
              ).material,
              isTrue,
            );
            lib.playback.playTracks(lib.library.tracks, 1, title: 'x');
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}
