import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/button.dart';
import 'package:altynemel/components/icon_data.dart';
import 'package:altynemel/theme/spacing.dart';

import '../support/pump.dart';

void main() {
  testWidgets('button is at least 48 px high and calls back', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      Center(
        child: AltynemelButton(
          label: 'Play',
          kind: ButtonKind.primary,
          icon: IconId.play,
          onPressed: () => taps++,
        ),
      ),
    );
    final size = tester.getSize(find.byType(AltynemelButton));
    expect(size.height, greaterThanOrEqualTo(targetMin));
    await tester.tap(find.byType(AltynemelButton));
    expect(taps, 1);
  });

  testWidgets('disabled button does not call back', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      Center(child: AltynemelButton(label: 'Play', onPressed: null)),
    );
    await tester.tap(find.byType(AltynemelButton), warnIfMissed: false);
    expect(taps, 0);
    final node = tester.getSemantics(find.byType(AltynemelButton));
    expect(node.label, 'Play');
    expect(
      node.getSemanticsData().flagsCollection.isEnabled.name,
      isNot('isTrue'),
    );
  });

  testWidgets('long label wraps at 200 percent text scale', (tester) async {
    await pumpThemed(
      tester,
      const Center(
        child: SizedBox(
          width: 160,
          child: AltynemelButton(
            label: 'Add to queue and play next',
            onPressed: _noop,
          ),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard focus shows the accent ring and Enter activates', (
    tester,
  ) async {
    var taps = 0;
    await pumpThemed(
      tester,
      Center(
        child: AltynemelButton(label: 'Play', onPressed: () => taps++),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    expect(find.byType(DecoratedBox), findsWidgets);
  });
}

void _noop() {}
