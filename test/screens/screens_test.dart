import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/screens/library_screen.dart';
import 'package:altynemel/screens/queue_screen.dart';
import 'package:altynemel/screens/settings_screen.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/theme/colors.dart';

import '../support/pump.dart';
import '../support/test_library.dart';

Widget _library(
  TestLibrary lib, {
  bool empty = false,
  VoidCallback? onOpenSettings,
}) {
  return LibraryScreen(
    albums: empty ? const [] : lib.library.albums,
    artists: empty ? const [] : lib.library.artists,
    tracks: empty ? const [] : lib.library.tracks,
    libraryEmpty: empty,
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
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await pumpThemed(tester, _library(lib));
    expect(find.bySemanticsLabel('Сарыарқа, Құрманғазы'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Artists'));
    await tester.pump();
    expect(find.bySemanticsLabel('Bjørk Ødegård, 1 track'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pump();
    expect(find.text('Балбырауын'), findsOneWidget);
  });

  testWidgets('empty library points to settings', (tester) async {
    final lib = TestLibrary(empty: true);
    addTearDown(lib.dispose);
    var opened = 0;
    await pumpThemed(
      tester,
      _library(lib, empty: true, onOpenSettings: () => opened++),
    );
    expect(find.text('No music yet'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Open settings'));
    expect(opened, 1);
  });

  testWidgets('queue lists the current track and the next ones', (
    tester,
  ) async {
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await pumpThemed(
      tester,
      QueueScreen(
        tracks: lib.library.tracks,
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
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(lib.app());
    await tester.tap(find.bySemanticsLabel('Settings').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Contrast'));
    await tester.pumpAndSettle();
    expect(lib.settings.theme, ThemeChoice.contrast);
    final context = tester.element(find.byType(Scaffold).first);
    expect(AltynemelColors.of(context), AltynemelColors.contrast);
  });

  testWidgets('reduce motion setting disables animations', (tester) async {
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(lib.app());
    expect(
      MediaQuery.disableAnimationsOf(
        tester.element(find.byType(Scaffold).first),
      ),
      isFalse,
    );
    lib.settings.setReduceMotion(true);
    await tester.pump();
    expect(
      MediaQuery.disableAnimationsOf(
        tester.element(find.byType(Scaffold).first),
      ),
      isTrue,
    );
  });

  testWidgets('settings screen without a picker shows the reason', (
    tester,
  ) async {
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(lib.wrap(SettingsScreen(settings: lib.settings)));
    await tester.scrollUntilVisible(
      find.text('Unavailable in this build.'),
      200,
    );
    expect(find.text('Unavailable in this build.'), findsOneWidget);
  });

  testWidgets('search filters the library and switches to it', (tester) async {
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(lib.app());
    await tester.tap(find.bySemanticsLabel('Settings').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ødeg');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Stille, Bjørk Ødegård'), findsOneWidget);
    expect(find.bySemanticsLabel('Сарыарқа, Құрманғазы'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
  });
}
