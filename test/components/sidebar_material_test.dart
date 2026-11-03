import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpSidebar(
  WidgetTester tester, {
  bool compact = false,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    SizedBox(
      width: compact ? 72 : 232,
      height: 600,
      child: Sidebar(
        compact: compact,
        destination: SidebarDestination.library,
        onDestination: (_) {},
        playlists: const [SidebarPlaylist(id: 'p', name: 'Road')],
        onPlaylist: (_) {},
        selectedPlaylistId: null,
        onSearch: () {},
      ),
    ),
    size: const Size(400, 700),
    style: style,
  );
}

BoxDecoration decorationOf(WidgetTester tester, Finder inside) {
  final box = tester.widget<Container>(
    find.ancestor(of: inside, matching: find.byType(Container)).first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the selected drawer item is a 56 px indicator pill', (
    tester,
  ) async {
    await pumpSidebar(tester);
    final item = find.text('Library');
    final decoration = decorationOf(tester, item);
    expect(decoration.color, scheme.secondaryContainer);
    expect(decoration.borderRadius, BorderRadius.circular(28));
    final box = find.ancestor(of: item, matching: find.byType(Container)).first;
    expect(tester.getSize(box).height, 56);
  });

  testWidgets('other drawer items have no indicator', (tester) async {
    await pumpSidebar(tester);
    expect(decorationOf(tester, find.text('Queue')).color, Colors.transparent);
  });

  testWidgets('the panel uses the low surface container without a border', (
    tester,
  ) async {
    await pumpSidebar(tester);
    final panel = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.color == scheme.surfaceContainerLow);
    expect(panel, isNotEmpty);
  });

  testWidgets('the rail shows a 56 by 32 indicator on the current item', (
    tester,
  ) async {
    await pumpSidebar(tester, compact: true);
    final indicator = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == scheme.secondaryContainer,
    );
    expect(indicator, findsOneWidget);
    expect(tester.getSize(indicator), const Size(56, 32));
  });

  testWidgets('the original style keeps its square selection', (tester) async {
    await pumpSidebar(tester, style: DesignStyle.altynemel);
    final decoration = decorationOf(tester, find.text('Library'));
    expect(decoration.color, isNot(scheme.secondaryContainer));
    expect(decoration.borderRadius, isNot(BorderRadius.circular(28)));
  });
}
