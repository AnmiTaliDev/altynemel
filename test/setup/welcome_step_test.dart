import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/steps/welcome_step.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';

void main() {
  for (final style in DesignStyle.values) {
    testWidgets('the welcome step lists the three parts in ${style.name}', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const SingleChildScrollView(child: WelcomeStep()),
        size: const Size(700, 600),
        style: style,
      );
      expect(find.text(Strings.setupWelcomeLook), findsOneWidget);
      expect(find.text(Strings.setupWelcomeMusic), findsOneWidget);
      expect(find.text(Strings.setupWelcomePlayback), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('each highlight is spoken as one label', (tester) async {
    await pumpThemed(
      tester,
      const SingleChildScrollView(child: WelcomeStep()),
      size: const Size(700, 600),
    );
    expect(find.bySemanticsLabel(Strings.setupWelcomeMusic), findsOneWidget);
  });
}
