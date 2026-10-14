import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/app.dart';
import 'package:altynemel/demo/demo_data.dart';
import 'package:altynemel/screens/library_screen.dart';
import 'package:altynemel/screens/queue_screen.dart';
import 'package:altynemel/screens/settings_screen.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/theme/colors.dart';

import '../support/pump.dart';

Widget _library({bool empty = false, VoidCallback? onOpenSettings}) {
  return LibraryScreen(
    albums: empty ? const [] : demoAlbums,
    artists: empty ? const [] : demoArtists,
    tracks: empty ? const [] : demoLibraryTracks,
    currentTrackId: null,
    isPlaying: false,
    selectedTrackId: null,
    onSelectTrack: (_) {},
    onPlayTrack: (_) {},
    onTrackMore: (_) {},
    onOpenAlbum: (_) {},
    onOpenArtist: (_) {},
    onOpenSettings: onOpenSettings ?? () {},
  );
}

void main() {
  testWidgets('library switches between albums, artists and tracks', (
    tester,
  ) async {
    await pumpThemed(tester, _library());
    expect(find.bySemanticsLabel('Сарыарқа, Құрманғазы'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Artists'));
    await tester.pump();
    expect(find.bySemanticsLabel('Bjørk Ødegård, 1 track'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pump();
    expect(find.text('Балбырауын'), findsOneWidget);
  });

  testWidgets('empty library points to settings', (tester) async {
    var opened = 0;
    await pumpThemed(
      tester,
      _library(empty: true, onOpenSettings: () => opened++),
    );
    expect(find.text('No music yet'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Open settings'));
    expect(opened, 1);
  });

  testWidgets('queue lists the current track and the next ones', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      QueueScreen(
        tracks: demoLibraryTracks,
        currentIndex: 0,
        isPlaying: true,
        selectedTrackId: null,
        onSelectTrack: (_) {},
        onPlayTrack: (_) {},
        onTrackMore: (_) {},
      ),
    );
    expect(find.text('Next up'), findsOneWidget);
    expect(find.text('Адай'), findsOneWidget);
  });

  testWidgets('empty queue shows a message', (tester) async {
    await pumpThemed(
      tester,
      QueueScreen(
        tracks: const [],
        currentIndex: null,
        isPlaying: false,
        selectedTrackId: null,
        onSelectTrack: (_) {},
        onPlayTrack: (_) {},
        onTrackMore: (_) {},
      ),
    );
    expect(find.text('The queue is empty'), findsOneWidget);
  });

  testWidgets('choosing a theme in settings changes the app theme', (
    tester,
  ) async {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AltynemelApp(settings: settings));
    await tester.tap(find.bySemanticsLabel('Settings').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Contrast'));
    await tester.pumpAndSettle();
    expect(settings.theme, ThemeChoice.contrast);
    final context = tester.element(find.byType(Scaffold).first);
    expect(AltynemelColors.of(context), AltynemelColors.contrast);
  });

  testWidgets('reduce motion setting disables animations', (tester) async {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AltynemelApp(settings: settings));
    final before = MediaQuery.disableAnimationsOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(before, isFalse);
    settings.setReduceMotion(true);
    await tester.pump();
    final after = MediaQuery.disableAnimationsOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(after, isTrue);
  });

  testWidgets(
    'folder button is disabled with a reason when no picker is wired',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(AltynemelApp(settings: AppSettings()));
      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Unavailable in this build.'),
        200,
        scrollable: find.descendant(
          of: find.byType(SettingsScreen),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Unavailable in this build.'), findsOneWidget);
    },
  );
}
