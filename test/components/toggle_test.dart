import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/toggle.dart';

import '../support/pump.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Toggle(
      title: 'Reduce motion',
      description: 'Replace transitions with instant changes',
      value: value,
      onChanged: (v) => setState(() => value = v),
    );
  }
}

void main() {
  testWidgets('tapping the row toggles the value', (tester) async {
    await pumpThemed(tester, const _Host());
    await tester.tap(find.text('Reduce motion'));
    await tester.pumpAndSettle();
    expect(tester.state<_HostState>(find.byType(_Host)).value, isTrue);
  });

  testWidgets('semantics expose the toggled state', (tester) async {
    await pumpThemed(tester, const _Host());
    final node = tester.getSemantics(
      find.bySemanticsLabel(
        'Reduce motion, Replace transitions with instant changes',
      ),
    );
    expect(node.flagsCollection.isToggled.name, 'isFalse');
  });

  testWidgets('disabled toggle shows the reason in words', (tester) async {
    await pumpThemed(
      tester,
      const Toggle(
        title: 'Download over mobile data',
        value: false,
        onChanged: null,
        disabledReason: 'Unavailable without a network',
      ),
    );
    expect(find.text('Unavailable without a network'), findsOneWidget);
  });

  testWidgets('row height is at least 64 px', (tester) async {
    await pumpThemed(tester, const _Host());
    expect(
      tester.getSize(find.byType(Toggle)).height,
      greaterThanOrEqualTo(64),
    );
  });
}
