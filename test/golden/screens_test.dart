import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/button.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/fonts.dart';
import '../support/test_library.dart';

Future<TestLibrary> pumpScreen(
  WidgetTester tester,
  String screen,
  AltynemelThemeId theme,
) async {
  tester.view.physicalSize = const Size(1100, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  final destination = switch (screen) {
    'queue' => SidebarDestination.queue,
    'settings' => SidebarDestination.settings,
    _ => SidebarDestination.library,
  };
  await tester.pumpWidget(
    lib.wrap(HomeScreen(initialDestination: destination), theme: theme),
  );
  await tester.pumpAndSettle();
  if (screen == 'playlist' || screen == 'queue') {
    await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AltynemelButton, 'Play'));
    await tester.pumpAndSettle();
  }
  if (screen == 'queue') {
    await tester.tap(find.bySemanticsLabel('Queue').first);
    await tester.pumpAndSettle();
  }
  return lib;
}

void main() {
  setUpAll(loadOnest);

  const screens = ['playlist', 'library', 'queue', 'settings'];

  for (final screen in screens) {
    for (final theme in AltynemelThemeId.values) {
      testWidgets('$screen in ${theme.name}', (tester) async {
        await pumpScreen(tester, screen, theme);
        await expectLater(
          find.byType(Scaffold).first,
          matchesGoldenFile('goldens/${screen}_${theme.name}.png'),
        );
      });
    }
  }
}
