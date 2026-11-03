import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/track_table.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpRow(
  WidgetTester tester, {
  bool current = false,
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    TrackTableRow(
      number: 1,
      title: 'fading memories',
      artist: 'june lu',
      duration: const Duration(minutes: 2),
      onSelect: () {},
      onPlay: () {},
      onMore: (_) {},
      showAlbum: false,
      isCurrent: current,
    ),
    size: const Size(900, 200),
    style: style,
  );
}

Color? background(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(TrackTableRow),
          matching: find.byType(Container),
        )
        .first,
  );
  return (box.decoration! as BoxDecoration).color;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the current row uses the secondary container', (tester) async {
    await pumpRow(tester, current: true);
    expect(background(tester), scheme.secondaryContainer);
  });

  testWidgets('an ordinary row is transparent', (tester) async {
    await pumpRow(tester);
    expect(background(tester), Colors.transparent);
  });

  testWidgets('the original current row keeps the surface color', (
    tester,
  ) async {
    await pumpRow(tester, current: true, style: DesignStyle.altynemel);
    expect(background(tester), isNot(scheme.secondaryContainer));
  });
}
