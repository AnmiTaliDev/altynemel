import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/track_table.dart';

import 'home_playback_test.dart' show pumpHome;

List<String> rowTitles(WidgetTester tester) => [
  for (final row in tester.widgetList<TrackTableRow>(
    find.byType(TrackTableRow),
  ))
    row.title,
];

Finder albumHeader() => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.header == true,
  ),
  matching: find.text('Сарыарқа'),
);

void main() {
  testWidgets('opening an album shows only its tracks', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Сарыарқа, Құрманғазы'));
    await tester.pumpAndSettle();
    expect(albumHeader(), findsOneWidget);
    expect(rowTitles(tester), ['Балбырауын', 'Адай']);
  });

  testWidgets('opening an artist shows that artist tracks', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Artists'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Құрманғазы, 2 tracks'));
    await tester.pumpAndSettle();
    expect(find.text('Artist'), findsOneWidget);
    expect(rowTitles(tester), ['Балбырауын', 'Адай']);
  });

  testWidgets('choosing Library in the sidebar leaves the album page', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Сарыарқа, Құрманғазы'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Library').first);
    await tester.pumpAndSettle();
    expect(albumHeader(), findsNothing);
    expect(find.bySemanticsLabel('Сарыарқа, Құрманғазы'), findsOneWidget);
  });
}
