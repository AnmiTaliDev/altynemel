import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/menu.dart';
import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/components/track_table.dart';
import 'package:altynemel/strings.dart';

import 'home_playback_test.dart' show pumpHome, startPlaylist;

List<String> rowTitles(WidgetTester tester) => [
  for (final row in tester.widgetList<TrackTableRow>(
    find.byType(TrackTableRow),
  ))
    row.title,
];

Finder artistHeader(String name) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.header == true,
  ),
  matching: find.text(name),
);

void main() {
  testWidgets('clicking an artist in a track row opens the artist page', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(TrackTableRow).at(3),
            matching: find.text('Құрманғазы'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(artistHeader('Құрманғазы'), findsOneWidget);
    expect(rowTitles(tester), ['Балбырауын', 'Адай']);
    expect(lib.playback.current, isNull);
  });

  testWidgets('each name in a multi artist track is its own link', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('sløwmind').first);
    await tester.pumpAndSettle();
    expect(artistHeader('sløwmind'), findsOneWidget);
    expect(rowTitles(tester), ['fading memories']);
  });

  testWidgets('the artist in the player bar opens the artist page', (
    tester,
  ) async {
    await pumpHome(tester);
    await startPlaylist(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(PlayerBar),
        matching: find.text('june lu'),
      ),
    );
    await tester.pumpAndSettle();
    expect(artistHeader('june lu'), findsOneWidget);
  });

  testWidgets('the track menu offers a go to artist item', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AltynemelIconButton && w.label == Strings.moreAbout('Адай'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(MenuPanel),
        matching: find.bySemanticsLabel('Go to Құрманғазы'),
      ),
    );
    await tester.pumpAndSettle();
    expect(artistHeader('Құрманғазы'), findsOneWidget);
  });
}
