import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/pill_tabs.dart';

import '../support/pump.dart';

void main() {
  testWidgets('selected option is marked by a check and by semantics', (
    tester,
  ) async {
    var picked = 'a';
    await pumpThemed(
      tester,
      Center(
        child: PillTabs<String>(
          semanticLabel: 'View',
          selected: picked,
          onSelected: (v) => picked = v,
          options: const [
            PillOption(value: 'a', label: 'Albums'),
            PillOption(value: 'b', label: 'Artists'),
          ],
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Albums'))
          .flagsCollection
          .isSelected
          .name,
      'isTrue',
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Artists'))
          .flagsCollection
          .isSelected
          .name,
      'isFalse',
    );
    expect(
      tester.getSize(find.bySemanticsLabel('Artists')).height,
      greaterThanOrEqualTo(40),
    );
    await tester.tap(find.bySemanticsLabel('Artists'));
    expect(picked, 'b');
  });
}
