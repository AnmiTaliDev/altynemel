import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/cover_art.dart';
import 'package:altynemel/components/media_tile.dart';
import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/components/screen_header.dart';
import 'package:altynemel/components/time_label.dart';
import 'package:altynemel/components/track_table.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/colors.dart';

import 'support/test_library.dart';

Future<TestLibrary> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1100, 700),
  void Function(TestLibrary lib)? preset,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  preset?.call(lib);
  await tester.pumpWidget(lib.app());
  await tester.pumpAndSettle();
  return lib;
}

BuildContext homeContext(WidgetTester tester) =>
    tester.element(find.byType(HomeScreen));

void main() {
  testWidgets('text size scales the text of the whole app', (tester) async {
    final lib = await pumpApp(tester);
    expect(MediaQuery.textScalerOf(homeContext(tester)).scale(10), 10);
    lib.settings.setValue(textScalePercent, 150);
    await tester.pumpAndSettle();
    expect(MediaQuery.textScalerOf(homeContext(tester)).scale(10), 15);
  });

  testWidgets('the accent color reaches the running theme', (tester) async {
    final lib = await pumpApp(tester);
    final before = Theme.of(homeContext(tester)).extension<AltynemelColors>()!;
    lib.settings.setValue(accentColor, AccentChoice.violet);
    await tester.pumpAndSettle();
    final after = Theme.of(homeContext(tester)).extension<AltynemelColors>()!;
    expect(after.accent, isNot(before.accent));
    expect(after.ground, before.ground);
    lib.settings.reset(accentColor);
    await tester.pumpAndSettle();
    final back = Theme.of(homeContext(tester)).extension<AltynemelColors>()!;
    expect(back.accent, before.accent);
  });

  Future<double> firstRowHeight(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Tracks').first);
    await tester.pumpAndSettle();
    return tester.getSize(find.byType(TrackTableRow).first).height;
  }

  testWidgets('row density changes the height of track rows', (tester) async {
    final lib = await pumpApp(tester);
    expect(await firstRowHeight(tester), 56);
    lib.settings.setValue(rowDensity, RowDensity.compact);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(TrackTableRow).first).height, 44);
    lib.settings.setValue(rowDensity, RowDensity.spacious);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(TrackTableRow).first).height, 72);
  });

  testWidgets('the row cover size follows the setting', (tester) async {
    final lib = await pumpApp(tester);
    await firstRowHeight(tester);
    final cover = find.descendant(
      of: find.byType(TrackTableRow).first,
      matching: find.byType(CoverArt),
    );
    expect(tester.getSize(cover).width, 40);
    lib.settings.setValue(rowCoverSize, 64);
    await tester.pumpAndSettle();
    expect(tester.getSize(cover).width, 64);
    expect(tester.getSize(find.byType(TrackTableRow).first).height, 68);
  });

  double headerLeft(WidgetTester tester) {
    final title = find.descendant(
      of: find.byType(ScreenHeader),
      matching: find.text('Library'),
    );
    return tester.getTopLeft(title).dx;
  }

  testWidgets('the page margin moves the content on a desktop layout', (
    tester,
  ) async {
    final lib = await pumpApp(tester);
    expect(headerLeft(tester), 232 + 32);
    lib.settings.setValue(pageMargin, 64);
    await tester.pumpAndSettle();
    expect(headerLeft(tester), 232 + 64);
  });

  testWidgets('the phone page margin moves the content on a phone layout', (
    tester,
  ) async {
    final lib = await pumpApp(tester, size: const Size(360, 720));
    expect(headerLeft(tester), 16);
    lib.settings.setValue(pageMarginPhone, 24);
    await tester.pumpAndSettle();
    expect(headerLeft(tester), 24);
  });

  testWidgets('the album tile size follows the setting', (tester) async {
    final lib = await pumpApp(tester);
    final cover = find.descendant(
      of: find.byType(MediaTile).first,
      matching: find.byType(CoverArt),
    );
    expect(tester.getSize(cover).width, 160);
    lib.settings.setValue(tileCoverSize, 220);
    await tester.pumpAndSettle();
    expect(tester.getSize(cover).width, 220);
  });

  testWidgets('the phone album tile size follows its own setting', (
    tester,
  ) async {
    final lib = await pumpApp(tester, size: const Size(360, 720));
    final cover = find.descendant(
      of: find.byType(MediaTile).first,
      matching: find.byType(CoverArt),
    );
    expect(tester.getSize(cover).width, 140);
    lib.settings.setValue(tileCoverSizePhone, 100);
    await tester.pumpAndSettle();
    expect(tester.getSize(cover).width, 100);
    lib.settings.setValue(tileCoverSize, 220);
    await tester.pumpAndSettle();
    expect(tester.getSize(cover).width, 100);
  });

  testWidgets('the player bar height follows the setting', (tester) async {
    final lib = await pumpApp(tester);
    final base = tester.getSize(find.byType(PlayerBar)).height;
    lib.settings.setValue(playerBarMinHeight, 150);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PlayerBar)).height, 150);
    lib.settings.reset(playerBarMinHeight);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PlayerBar)).height, base);
  });

  testWidgets('the album column appears when enough space is free', (
    tester,
  ) async {
    final lib = await pumpApp(tester);
    await firstRowHeight(tester);
    expect(find.text('Album'), findsOneWidget);
    lib.settings.setValue(albumColumnMinWidth, 900);
    await tester.pumpAndSettle();
    expect(find.text('Album'), findsNothing);
    lib.settings.setValue(albumColumnMinWidth, 300);
    await tester.pumpAndSettle();
    expect(find.text('Album'), findsOneWidget);
  });

  testWidgets('track numbers can be hidden', (tester) async {
    final lib = await pumpApp(tester);
    await firstRowHeight(tester);
    expect(find.text('#'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    lib.settings.setValue(showTrackNumbers, false);
    await tester.pumpAndSettle();
    expect(find.text('#'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(TrackTableRow).first,
        matching: find.text('1'),
      ),
      findsNothing,
    );
  });

  testWidgets('track durations can be hidden', (tester) async {
    final lib = await pumpApp(tester);
    await firstRowHeight(tester);
    expect(find.text('Time'), findsOneWidget);
    lib.settings.setValue(showTrackDurations, false);
    await tester.pumpAndSettle();
    expect(find.text('Time'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(TrackTableRow).first,
        matching: find.byType(TimeLabel),
      ),
      findsNothing,
    );
  });

  testWidgets('short tracks can be hidden from the library', (tester) async {
    final lib = await pumpApp(tester);
    expect(lib.library.tracks.length, 4);
    lib.settings.setValue(minimumTrackSeconds, 200);
    await tester.pumpAndSettle();
    expect(lib.library.tracks.length, 3);
    expect(
      lib.library.tracks.every(
        (t) => t.duration >= const Duration(seconds: 200),
      ),
      isTrue,
    );
    lib.settings.reset(minimumTrackSeconds);
    await tester.pumpAndSettle();
    expect(lib.library.tracks.length, 4);
  });
}
