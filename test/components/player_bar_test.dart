import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/demo/demo_screen.dart';

import '../support/pump.dart';

void main() {
  testWidgets('volume is shown at 1000 px and hidden at 800 px', (
    tester,
  ) async {
    await pumpThemed(tester, const DemoScreen(), size: const Size(1000, 700));
    expect(find.bySemanticsLabel('Volume'), findsOneWidget);
    await pumpThemed(tester, const DemoScreen(), size: const Size(800, 700));
    expect(find.bySemanticsLabel('Volume'), findsNothing);
    expect(find.bySemanticsLabel('Queue'), findsWidgets);
  });

  testWidgets('album column is hidden below 720 px', (tester) async {
    await pumpThemed(tester, const DemoScreen(), size: const Size(1000, 700));
    expect(find.text('Album'), findsOneWidget);
    await pumpThemed(tester, const DemoScreen(), size: const Size(700, 700));
    expect(find.text('Album'), findsNothing);
  });

  testWidgets('like button toggles its label', (tester) async {
    await pumpThemed(tester, const DemoScreen());
    await tester.tap(find.bySemanticsLabel('Add to favorites'));
    await tester.pump();
    expect(find.bySemanticsLabel('Remove from favorites'), findsOneWidget);
  });

  testWidgets('play and pause update the bar', (tester) async {
    await pumpThemed(tester, const DemoScreen());
    expect(find.bySemanticsLabel('Pause'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Pause').last);
    await tester.pump();
    expect(find.bySemanticsLabel('Play'), findsWidgets);
  });

  testWidgets('seek bar speaks position in words', (tester) async {
    await pumpThemed(tester, const DemoScreen());
    final node = tester.getSemantics(find.bySemanticsLabel('Seek'));
    expect(node.value, '48 seconds of 2 minutes 27 seconds');
  });
}
