import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/track_table.dart';
import 'package:altynemel/screens/home_screen.dart';

import '../support/test_library.dart';
import 'home_playback_test.dart' show pumpHome, startPlaylist;

void main() {
  testWidgets('left and right arrows seek by five seconds', (tester) async {
    final lib = await pumpHome(tester);
    await startPlaylist(tester);
    final before = lib.playback.position.value;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(lib.playback.position.value - before, const Duration(seconds: 5));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(lib.playback.position.value, before);
  });

  testWidgets('transport buttons show their shortcuts in tooltips', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.byTooltip('Next track (Ctrl+Right)'), findsOneWidget);
    expect(find.byTooltip('Previous track (Ctrl+Left)'), findsOneWidget);
    expect(find.byTooltip('Play (Space)'), findsOneWidget);
  });

  testWidgets('up and down arrows move between track rows', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    final rows = find.byType(TrackTableRow);
    expect(rows, findsAtLeastNWidgets(2));
    final first = find.descendant(
      of: rows.at(0),
      matching: find.byType(GestureDetector),
    );
    Focus.of(tester.element(first.first)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus!.context!;
    expect(
      find.descendant(
        of: rows.at(1),
        matching: find.byElementPredicate((e) => e == focused),
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    final back = FocusManager.instance.primaryFocus!.context!;
    expect(
      find.descendant(
        of: rows.at(0),
        matching: find.byElementPredicate((e) => e == back),
      ),
      findsOneWidget,
    );
  });

  testWidgets('now playing title is a live region', (tester) async {
    await pumpHome(tester);
    final live = find.ancestor(
      of: find.text('Nothing playing'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.liveRegion == true,
      ),
    );
    expect(live, findsOneWidget);
  });

  testWidgets('home screen survives 200 percent text without errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1100, 700),
          textScaler: TextScaler.linear(2),
        ),
        child: lib.wrap(const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
