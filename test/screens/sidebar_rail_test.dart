import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/screens/playlist_screen.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/theme/spacing.dart';

import '../support/test_library.dart';

Future<void> pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  await tester.pumpWidget(lib.wrap(const HomeScreen()));
  await tester.pumpAndSettle();
}

double sidebarWidthNow(WidgetTester tester) =>
    tester.getSize(find.byType(Sidebar)).width;

void main() {
  testWidgets('below 800 px the sidebar is a rail without the search field', (
    tester,
  ) async {
    await pumpAt(tester, const Size(700, 600));
    expect(sidebarWidthNow(tester), sidebarRailWidth);
    expect(find.byType(TextField), findsNothing);
    for (final label in ['Search', 'Library', 'Queue', 'Settings']) {
      expect(
        find.descendant(
          of: find.byType(Sidebar),
          matching: find.bySemanticsLabel(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('from 800 px the full sidebar is shown', (tester) async {
    await pumpAt(tester, const Size(800, 600));
    expect(sidebarWidthNow(tester), sidebarWidth);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('rail playlists open by their name', (tester) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistScreen), findsOneWidget);
  });

  testWidgets('rail search expands the sidebar and focuses the field', (
    tester,
  ) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarWidth);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
  });

  testWidgets('escape closes the expanded sidebar', (tester) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarRailWidth);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('tapping the content next to the expanded sidebar closes it', (
    tester,
  ) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(600, 300));
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarRailWidth);
  });

  testWidgets('choosing a destination closes the expanded sidebar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Sidebar),
        matching: find.bySemanticsLabel('Queue'),
      ),
    );
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarRailWidth);
  });

  testWidgets('ctrl+F expands the rail and focuses the search field', (
    tester,
  ) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarWidth);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
  });

  testWidgets('widening the window drops the expanded state', (tester) async {
    await pumpAt(tester, const Size(700, 600));
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1000, 600);
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarWidth);
    tester.view.physicalSize = const Size(700, 600);
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), sidebarRailWidth);
  });

  testWidgets('the sidebar width follows the setting', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(lib.wrap(const HomeScreen()));
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), 232);
    lib.settings.setValue(sidebarExpandedWidth, 300);
    await tester.pumpAndSettle();
    expect(sidebarWidthNow(tester), 300);
  });
}
