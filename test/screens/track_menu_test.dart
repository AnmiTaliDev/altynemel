import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/menu.dart';
import 'package:altynemel/components/pressable.dart';
import 'package:altynemel/components/track_table.dart';
import 'package:altynemel/strings.dart';

import '../support/test_library.dart';
import 'home_playback_test.dart' show pumpHome;

Future<TestLibrary> openMenu(WidgetTester tester) async {
  final lib = await pumpHome(tester);
  await tester.tap(find.bySemanticsLabel('Tracks'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byWidgetPredicate(
      (w) =>
          w is AltynemelIconButton &&
          w.label == Strings.moreAbout('Natt over fjorden'),
    ),
  );
  await tester.pumpAndSettle();
  return lib;
}

Finder inMenu(String label) => find.descendant(
  of: find.byType(MenuPanel),
  matching: find.bySemanticsLabel(label),
);

void main() {
  testWidgets('the more button opens the track menu', (tester) async {
    await openMenu(tester);
    expect(find.bySemanticsLabel('Play next'), findsOneWidget);
    expect(find.bySemanticsLabel('Add to queue'), findsOneWidget);
    expect(inMenu('Add to favorites'), findsOneWidget);
  });

  testWidgets('add to queue enqueues the track and closes the menu', (
    tester,
  ) async {
    final lib = await openMenu(tester);
    await tester.tap(find.bySemanticsLabel('Add to queue'));
    await tester.pumpAndSettle();
    expect(lib.playback.queueTracks.map((t) => t.title), ['Natt over fjorden']);
    expect(find.bySemanticsLabel('Add to queue'), findsNothing);
  });

  testWidgets('like toggles the favorite state', (tester) async {
    final lib = await openMenu(tester);
    final id = lib.library.tracks
        .firstWhere((t) => t.title == 'Natt over fjorden')
        .id;
    await tester.tap(inMenu('Add to favorites'));
    await tester.pumpAndSettle();
    expect(lib.library.isLiked(id), isTrue);
  });

  testWidgets('a new playlist can be created from the menu', (tester) async {
    final lib = await openMenu(tester);
    await tester.tap(find.bySemanticsLabel('Add to playlist'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Shared with me'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('New playlist'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Road');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final created = lib.library.playlists.firstWhere((p) => p.name == 'Road');
    expect(lib.library.playlistTracks(created.id).map((t) => t.title), [
      'Natt over fjorden',
    ]);
  });

  testWidgets('an existing playlist receives the track', (tester) async {
    final lib = await openMenu(tester);
    await tester.tap(find.bySemanticsLabel('Add to playlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Shared with me').last);
    await tester.pumpAndSettle();
    final shared = lib.library.playlists.firstWhere(
      (p) => p.name == sharedPlaylistName,
    );
    expect(
      lib.library.playlistTracks(shared.id).map((t) => t.title),
      contains('Natt over fjorden'),
    );
  });

  testWidgets('escape closes the menu', (tester) async {
    await openMenu(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Play next'), findsNothing);
  });

  testWidgets('a right click opens the menu', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    final row = find.byType(TrackTableRow).first;
    await tester.tap(row, buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Play next'), findsOneWidget);
  });

  testWidgets('the menu key opens the menu from a focused row', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    final row = find.byType(TrackTableRow).first;
    final inner = find.descendant(
      of: find.descendant(of: row, matching: find.byType(Pressable)),
      matching: find.byType(GestureDetector),
    );
    Focus.of(tester.element(inner.first)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Play next'), findsOneWidget);
  });
}
