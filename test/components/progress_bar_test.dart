import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/progress_bar.dart';

import '../support/pump.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  double value = 48;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        child: ProgressBar(
          value: value,
          max: 147,
          semanticLabel: 'Seek',
          semanticValueOf: (v) => '$v seconds',
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('arrow keys move by 5 seconds', (tester) async {
    await pumpThemed(tester, const _Host());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(tester.state<_HostState>(find.byType(_Host)).value, 53);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(tester.state<_HostState>(find.byType(_Host)).value, 43);
  });

  testWidgets('tap seeks proportionally', (tester) async {
    await pumpThemed(tester, const _Host());
    final rect = tester.getRect(find.byType(ProgressBar));
    await tester.tapAt(Offset(rect.left + rect.width / 2, rect.center.dy));
    await tester.pump();
    expect(
      tester.state<_HostState>(find.byType(_Host)).value,
      closeTo(73.5, 0.01),
    );
  });

  testWidgets('touch height is 48 and semantics expose the value', (
    tester,
  ) async {
    await pumpThemed(tester, const _Host());
    expect(tester.getSize(find.byType(ProgressBar)).height, 48);
    final node = tester.getSemantics(find.bySemanticsLabel('Seek'));
    expect(node.value, '48.0 seconds');
  });

  testWidgets('value is clamped to the range', (tester) async {
    await pumpThemed(tester, const _Host());
    final rect = tester.getRect(find.byType(ProgressBar));
    await tester.tapAt(Offset(rect.right - 0.5, rect.center.dy));
    await tester.pump();
    expect(
      tester.state<_HostState>(find.byType(_Host)).value,
      lessThanOrEqualTo(147),
    );
  });
}
