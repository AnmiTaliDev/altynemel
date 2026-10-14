import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/menu.dart';
import 'package:altynemel/components/track_table.dart';
import 'package:altynemel/strings.dart';

import 'home_playback_test.dart' show pumpHome;

Finder moreButton(String title) => find.byWidgetPredicate(
  (w) => w is AltynemelIconButton && w.label == Strings.moreAbout(title),
);

Finder inMenu(String label) => find.descendant(
  of: find.byType(MenuPanel),
  matching: find.bySemanticsLabel(label),
);

Finder albumHeader(String name) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.header == true,
  ),
  matching: find.text(name),
);

Future<void> tallWindow(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1100, 1000);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the queue menu removes an upcoming track', (tester) async {
    final lib = await pumpHome(tester);
    await lib.playback.playTracks(lib.library.tracks, 0, title: 'Library');
    await tester.tap(find.bySemanticsLabel('Queue').first);
    await tester.pumpAndSettle();
    final removed = lib.playback.queueTracks[1];
    final count = lib.playback.queueTracks.length;
    await tester.tap(moreButton(removed.title));
    await tester.pumpAndSettle();
    await tester.tap(inMenu('Remove from queue'));
    await tester.pumpAndSettle();
    expect(lib.playback.queueTracks.length, count - 1);
    expect(
      lib.playback.queueTracks.map((t) => t.id),
      isNot(contains(removed.id)),
    );
    expect(find.byType(MenuPanel), findsNothing);
  });

  testWidgets('the current queue entry has no remove item', (tester) async {
    final lib = await pumpHome(tester);
    await lib.playback.playTracks(lib.library.tracks, 0, title: 'Library');
    await tester.tap(find.bySemanticsLabel('Queue').first);
    await tester.pumpAndSettle();
    await tester.tap(moreButton(lib.playback.current!.title));
    await tester.pumpAndSettle();
    expect(inMenu('Play next'), findsOneWidget);
    expect(inMenu('Remove from queue'), findsNothing);
  });

  testWidgets('the library menu has no remove from queue item', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(moreButton('Natt over fjorden'));
    await tester.pumpAndSettle();
    expect(inMenu('Remove from queue'), findsNothing);
  });

  testWidgets('the menu opens next to its button', (tester) async {
    await pumpHome(tester);
    await tallWindow(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    final button = tester.getRect(moreButton('Natt over fjorden'));
    await tester.tap(moreButton('Natt over fjorden'));
    await tester.pumpAndSettle();
    final panel = tester.getRect(find.byType(MenuPanel));
    expect(panel.right, closeTo(button.right, 0.5));
    final below = panel.top >= button.bottom;
    final above = panel.bottom <= button.top;
    expect(below || above, isTrue);
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(panel.left, greaterThanOrEqualTo(0));
    expect(panel.bottom, lessThanOrEqualTo(screen.height));
  });

  testWidgets('the menu stays inside a short window', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(moreButton('Natt over fjorden'));
    await tester.pumpAndSettle();
    final panel = tester.getRect(find.byType(MenuPanel));
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(panel.top, greaterThanOrEqualTo(0));
    expect(panel.bottom, lessThanOrEqualTo(screen.height));
    expect(panel.right, lessThanOrEqualTo(screen.width));
  });

  testWidgets('a right click opens the menu at the pointer', (tester) async {
    await pumpHome(tester);
    await tallWindow(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    final row = find.byType(TrackTableRow).at(1);
    final point = tester.getTopLeft(row) + const Offset(60, 20);
    await tester.tapAt(point, buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    final panel = tester.getRect(find.byType(MenuPanel));
    expect(panel.left, closeTo(point.dx, 0.5));
    expect(panel.top, closeTo(point.dy + 4, 0.5));
  });

  testWidgets('clicking an album in a track row opens the album page', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(TrackTableRow),
            matching: find.text('Stille'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(albumHeader('Stille'), findsOneWidget);
    expect(find.byType(TrackTableRow), findsOneWidget);
    expect(lib.playback.current, isNull);
  });

  testWidgets('the menu goes to the album of the track', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(moreButton('Natt over fjorden'));
    await tester.pumpAndSettle();
    await tester.tap(inMenu('Go to album Stille'));
    await tester.pumpAndSettle();
    expect(albumHeader('Stille'), findsOneWidget);
  });

  testWidgets('a track without an album has no album item', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(moreButton('fading memories'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Go to album'), findsNothing);
  });
}
