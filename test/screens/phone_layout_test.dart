import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/layout_mode.dart';
import 'package:altynemel/components/mini_player.dart';
import 'package:altynemel/components/phone_nav.dart';
import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/components/search_field.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/screens/now_playing_screen.dart';
import 'package:altynemel/screens/playlist_screen.dart';
import 'package:altynemel/screens/playlists_screen.dart';
import 'package:altynemel/settings/catalog.dart';

import '../support/test_library.dart';

Future<TestLibrary> pumpPhone(
  WidgetTester tester, {
  Size size = const Size(360, 720),
  SidebarDestination destination = SidebarDestination.library,
}) async {
  tester.view.physicalSize = size;
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

Finder navItem(String label) => find.descendant(
  of: find.byType(PhoneNav),
  matching: find.bySemanticsLabel(label),
);

void main() {
  testWidgets('phone width swaps the sidebar and the bar for tabs', (
    tester,
  ) async {
    await pumpPhone(tester);
    expect(find.byType(PhoneNav), findsOneWidget);
    expect(find.byType(Sidebar), findsNothing);
    expect(find.byType(PlayerBar), findsNothing);
    expect(find.byType(SearchField), findsOneWidget);
  });

  testWidgets('the phone layout ends at 600 px', (tester) async {
    await pumpPhone(tester, size: Size(phoneBelow - 1, 700));
    expect(find.byType(PhoneNav), findsOneWidget);
    await pumpPhone(tester, size: const Size(phoneBelow, 700));
    expect(find.byType(PhoneNav), findsNothing);
    expect(find.byType(Sidebar), findsOneWidget);
  });

  testWidgets('the mini player appears with a track and opens the full view', (
    tester,
  ) async {
    final lib = await pumpPhone(tester);
    expect(find.byType(MiniPlayer), findsNothing);
    lib.playback.playTracks(lib.library.tracks, 1, title: 'Playing');
    await tester.pumpAndSettle();
    expect(find.byType(MiniPlayer), findsOneWidget);
    await tester.tap(find.byType(MiniPlayer));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsOneWidget);
    expect(find.byType(PhoneNav), findsNothing);
    await tester.tap(find.bySemanticsLabel('Collapse'));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsNothing);
    expect(find.byType(PhoneNav), findsOneWidget);
  });

  testWidgets('the playlists tab lists playlists and opens one with a back', (
    tester,
  ) async {
    await pumpPhone(tester);
    await tester.tap(navItem('Playlists'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistsScreen), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('1 song'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistScreen), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistsScreen), findsOneWidget);
  });

  testWidgets('tabs switch between library, queue and settings', (
    tester,
  ) async {
    await pumpPhone(tester);
    await tester.tap(navItem('Queue'));
    await tester.pumpAndSettle();
    expect(find.text('Queue'), findsWidgets);
    expect(find.byType(SearchField), findsNothing);
    await tester.tap(navItem('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    await tester.tap(navItem('Library'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchField), findsOneWidget);
  });

  testWidgets('track rows have no table header or number column', (
    tester,
  ) async {
    final lib = await pumpPhone(tester);
    lib.playback.playTracks(lib.library.tracks, 0, title: 'Playing');
    await tester.pumpAndSettle();
    await tester.tap(navItem('Queue'));
    await tester.pumpAndSettle();
    expect(find.text('#'), findsNothing);
    expect(find.text('Title'), findsNothing);
    expect(find.text('Time'), findsNothing);
  });

  testWidgets('albums use two columns at 360 px', (tester) async {
    await pumpPhone(tester);
    final tiles = find.bySemanticsLabel(RegExp('Stille|Unknown album'));
    final first = tester.getTopLeft(tiles.first).dy;
    final second = tester.getTopLeft(tiles.last).dy;
    expect(second, first);
  });

  testWidgets('the back button walks out of the open views', (tester) async {
    final lib = await pumpPhone(tester);
    await tester.tap(navItem('Playlists'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(PlaylistsScreen), findsOneWidget);
    lib.playback.playTracks(lib.library.tracks, 1, title: 'Playing');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MiniPlayer));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsNothing);
    expect(find.byType(PlaylistsScreen), findsOneWidget);
  });

  test('the default threshold setting matches the layout constant', () {
    expect(phoneLayoutBelow.defaultValue, phoneBelow);
  });

  testWidgets('the phone threshold follows the setting', (tester) async {
    final lib = await pumpPhone(tester, size: const Size(700, 700));
    expect(find.byType(PhoneNav), findsNothing);
    lib.settings.setValue(phoneLayoutBelow, 800);
    await tester.pumpAndSettle();
    expect(find.byType(PhoneNav), findsOneWidget);
    lib.settings.setValue(phoneLayoutBelow, 300);
    await tester.pumpAndSettle();
    expect(find.byType(PhoneNav), findsNothing);
  });
}
