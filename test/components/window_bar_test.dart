import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/window_bar.dart';

import '../support/pump.dart';

void main() {
  testWidgets('has three labelled buttons of at least 40 px', (tester) async {
    var minimized = 0;
    var toggled = 0;
    var closed = 0;
    await pumpThemed(
      tester,
      WindowBar(
        maximized: false,
        onMinimize: () => minimized++,
        onToggleMaximize: () => toggled++,
        onClose: () => closed++,
      ),
    );
    for (final label in ['Minimize', 'Maximize', 'Close']) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(40), reason: label);
      expect(size.height, greaterThanOrEqualTo(40), reason: label);
    }
    await tester.tap(find.bySemanticsLabel('Minimize'));
    await tester.tap(find.bySemanticsLabel('Maximize'));
    await tester.tap(find.bySemanticsLabel('Close'));
    expect([minimized, toggled, closed], [1, 1, 1]);
  });

  testWidgets('the maximize button reads Restore when maximized', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      WindowBar(
        maximized: true,
        onMinimize: () {},
        onToggleMaximize: () {},
        onClose: () {},
      ),
    );
    expect(find.bySemanticsLabel('Restore'), findsOneWidget);
    expect(find.bySemanticsLabel('Maximize'), findsNothing);
  });

  testWidgets('bar is 40 px high', (tester) async {
    await pumpThemed(
      tester,
      WindowBar(
        maximized: false,
        onMinimize: () {},
        onToggleMaximize: () {},
        onClose: () {},
      ),
    );
    expect(tester.getSize(find.byType(WindowBar)).height, 40);
  });
}
