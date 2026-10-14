import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/icon_data.dart';

import '../support/pump.dart';

void main() {
  testWidgets('sizes follow the pointer and touch targets', (tester) async {
    await pumpThemed(
      tester,
      Column(
        children: [
          AltynemelIconButton(
            icon: IconId.queue,
            label: 'Queue',
            onPressed: () {},
          ),
          AltynemelIconButton(
            icon: IconId.queue,
            label: 'Queue compact',
            compact: true,
            onPressed: () {},
          ),
        ],
      ),
    );
    expect(tester.getSize(find.bySemanticsLabel('Queue')).height, 48);
    expect(tester.getSize(find.bySemanticsLabel('Queue compact')).height, 40);
  });

  testWidgets('exposes label and toggled state', (tester) async {
    await pumpThemed(
      tester,
      AltynemelIconButton(
        icon: IconId.shuffle,
        label: 'Shuffle',
        pressed: true,
        onPressed: () {},
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Shuffle'));
    expect(node.label, 'Shuffle');
    expect(node.flagsCollection.isToggled.name, 'isTrue');
  });
}
