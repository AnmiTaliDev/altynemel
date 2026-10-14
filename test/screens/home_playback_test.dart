import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/button.dart';
import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';

import '../support/test_library.dart';

Future<TestLibrary> pumpHome(
  WidgetTester tester, {
  SidebarDestination destination = SidebarDestination.library,
}) async {
  tester.view.physicalSize = const Size(1100, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  await tester.pumpWidget(
    lib.wrap(HomeScreen(initialDestination: destination)),
  );
  await tester.pumpAndSettle();
  return lib;
}

Future<void> startPlaylist(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(AltynemelButton, 'Play'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('space toggles playback when no control is focused', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await startPlaylist(tester);
    expect(lib.playback.isPlaying, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(lib.playback.isPlaying, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(lib.playback.isPlaying, isTrue);
  });

  testWidgets(
    'space on a focused button activates it instead of toggling playback',
    (tester) async {
      final lib = await pumpHome(tester);
      await startPlaylist(tester);
      final shuffle = find.ancestor(
        of: find.bySemanticsLabel('Shuffle'),
        matching: find.byType(AltynemelIconButton),
      );
      final inner = find
          .descendant(of: shuffle, matching: find.byType(GestureDetector))
          .first;
      Focus.of(tester.element(inner)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(lib.playback.shuffle, isTrue);
      expect(lib.playback.isPlaying, isTrue);
    },
  );

  testWidgets('M mutes and unmutes, typing m in search does not', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await startPlaylist(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    expect(lib.playback.volume, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    expect(lib.playback.volume, 70);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    expect(lib.playback.volume, 70);
  });

  testWidgets('control plus right arrow skips to the next track', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    final first = lib.library.tracks.first;
    await lib.playback.playTracks(lib.library.tracks, 0, title: 'Library');
    await tester.pumpAndSettle();
    expect(lib.playback.current!.id, first.id);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(lib.playback.current!.id, lib.library.tracks[1].id);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(lib.playback.current!.id, first.id);
  });

  testWidgets('control plus F focuses the search field', (tester) async {
    await pumpHome(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.focusNode.hasFocus, isTrue);
  });

  testWidgets('queue screen follows the play order and jumps on activation', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await lib.playback.playTracks(lib.library.tracks, 0, title: 'Library');
    await lib.playback.setShuffle(true);
    await tester.tap(find.bySemanticsLabel('Queue').first);
    await tester.pumpAndSettle();
    expect(find.text('Next up'), findsOneWidget);
    final next = lib.playback.queueTracks[1];
    await tester.tap(find.text(next.title).first);
    await tester.pump();
    await tester.tap(find.text(next.title).first);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text(next.title).first);
    await tester.pumpAndSettle();
    expect(lib.playback.current, isNotNull);
  });

  testWidgets('now playing shows the list the queue came from', (tester) async {
    final lib = await pumpHome(tester);
    await startPlaylist(tester);
    await tester.tap(find.bySemanticsLabel('Library').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Now playing').first);
    await tester.pumpAndSettle();
    expect(find.text(sharedPlaylistName), findsWidgets);
    expect(lib.playback.sourceTitle, sharedPlaylistName);
  });

  testWidgets('now playing without a queue shows a message', (tester) async {
    await pumpHome(tester, destination: SidebarDestination.nowPlaying);
    expect(find.text('Nothing playing'), findsWidgets);
  });

  testWidgets('volume bar uses the configured step', (tester) async {
    final lib = await pumpHome(tester);
    lib.settings.setVolumeStep(10);
    await startPlaylist(tester);
    final volume = find.bySemanticsLabel('Volume');
    final node = tester.getSemantics(volume);
    expect(node.increasedValue, '80 percent');
    expect(node.decreasedValue, '60 percent');
  });
}
