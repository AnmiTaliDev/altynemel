import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/button.dart';
import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/settings/catalog.dart';

import '../support/test_library.dart';

Future<TestLibrary> pumpPlaying(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(lib.wrap(const HomeScreen()));
  await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(AltynemelButton, 'Play'));
  await tester.pumpAndSettle();
  return lib;
}

void main() {
  testWidgets('volume is shown at 1000 px and hidden at 800 px', (
    tester,
  ) async {
    await pumpPlaying(tester, const Size(1000, 700));
    expect(find.bySemanticsLabel('Volume'), findsOneWidget);
    await pumpPlaying(tester, const Size(800, 700));
    expect(find.bySemanticsLabel('Volume'), findsNothing);
    expect(find.bySemanticsLabel('Queue'), findsWidgets);
  });

  testWidgets('narrow bar keeps the title on one line and drops the modes', (
    tester,
  ) async {
    await pumpPlaying(tester, const Size(640, 700));
    final title = find.descendant(
      of: find.byType(PlayerBar),
      matching: find.text('fading memories'),
    );
    expect(tester.getSize(title).height, lessThan(24));
    expect(tester.getSize(find.byType(PlayerBar)).height, lessThan(110));
    expect(find.bySemanticsLabel('Shuffle'), findsNothing);
    expect(find.bySemanticsLabel('Repeat'), findsNothing);
    expect(find.bySemanticsLabel('Pause'), findsWidgets);
    expect(find.bySemanticsLabel('Next track'), findsWidgets);
    expect(find.bySemanticsLabel('Queue'), findsWidgets);
    await pumpPlaying(tester, const Size(1000, 700));
    expect(find.bySemanticsLabel('Shuffle'), findsWidgets);
  });

  testWidgets('album column is hidden below 720 px', (tester) async {
    await pumpPlaying(tester, const Size(1000, 700));
    expect(find.text('Album'), findsOneWidget);
    await pumpPlaying(tester, const Size(700, 700));
    expect(find.text('Album'), findsNothing);
  });

  testWidgets('bar shows nothing playing and disabled controls at start', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(
      lib.wrap(
        const HomeScreen(initialDestination: SidebarDestination.library),
      ),
    );
    expect(find.text('Nothing playing'), findsOneWidget);
    final play = tester.getSemantics(find.bySemanticsLabel('Play'));
    expect(play.flagsCollection.isEnabled.name, isNot('isTrue'));
  });

  testWidgets('playing the playlist fills the bar and like is stored', (
    tester,
  ) async {
    final lib = await pumpPlaying(tester, const Size(1100, 700));
    expect(find.text('fading memories'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Add to favorites'));
    await tester.pump();
    expect(find.bySemanticsLabel('Remove from favorites'), findsOneWidget);
    expect(lib.database.likedIds(), isNotEmpty);
  });

  testWidgets('play and pause update the bar', (tester) async {
    await pumpPlaying(tester, const Size(1100, 700));
    expect(find.bySemanticsLabel('Pause'), findsWidgets);
    await tester.tap(find.widgetWithText(AltynemelButton, 'Pause'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Play'), findsWidgets);
  });

  testWidgets('seek bar speaks position in words', (tester) async {
    await pumpPlaying(tester, const Size(1100, 700));
    final node = tester.getSemantics(find.bySemanticsLabel('Seek'));
    expect(node.value, '0 seconds of 2 minutes 27 seconds');
  });

  test('the default compact bar threshold matches the layout constant', () {
    expect(compactPlayerBarBelow.defaultValue, playerBarCompactBelow);
  });

  testWidgets('the compact bar threshold follows the setting', (tester) async {
    final lib = await pumpPlaying(tester, const Size(1000, 700));
    expect(find.bySemanticsLabel('Shuffle'), findsWidgets);
    lib.settings.setValue(compactPlayerBarBelow, 1200);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Shuffle'), findsNothing);
    lib.settings.setValue(compactPlayerBarBelow, 500);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Shuffle'), findsWidgets);
  });
}
