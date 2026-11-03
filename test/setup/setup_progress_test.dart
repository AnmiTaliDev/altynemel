import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/setup_progress.dart';
import 'package:altynemel/setup/setup_step.dart';
import 'package:altynemel/setup/setup_wizard.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';

Future<void> pumpWizard(WidgetTester tester, Size size) async {
  final settings = AppSettings()..setSetupCompleted(false);
  addTearDown(settings.dispose);
  await pumpThemed(tester, SetupWizard(settings: settings), size: size);
}

void main() {
  testWidgets('a wide window shows the vertical stepper and the brand', (
    tester,
  ) async {
    await pumpWizard(tester, const Size(1100, 800));
    expect(find.byType(SetupStepper), findsOneWidget);
    expect(find.byType(SetupSegments), findsNothing);
    expect(find.text(Strings.appName), findsOneWidget);
    for (final step in SetupStep.values) {
      expect(find.text(step.label), findsOneWidget);
    }
  });

  testWidgets('a narrow window shows the segmented progress', (tester) async {
    await pumpWizard(tester, const Size(360, 700));
    expect(find.byType(SetupSegments), findsOneWidget);
    expect(find.byType(SetupStepper), findsNothing);
    expect(find.textContaining('Step 1 of 5'), findsOneWidget);
  });

  testWidgets('the segments follow the current step', (tester) async {
    await pumpWizard(tester, const Size(360, 700));
    await tester.tap(find.text(Strings.setupNext));
    await tester.pumpAndSettle();
    expect(find.textContaining('Step 2 of 5'), findsOneWidget);
    expect(find.textContaining(SetupStep.appearance.label), findsWidgets);
  });

  testWidgets('the current step is marked as selected and the rest are not', (
    tester,
  ) async {
    await pumpWizard(tester, const Size(1100, 800));
    await tester.tap(find.text(Strings.setupNext));
    await tester.pumpAndSettle();
    for (var i = 0; i < SetupStep.values.length; i++) {
      final node = tester.getSemantics(
        find.bySemanticsLabel(
          RegExp('Step ${i + 1} of 5, ${SetupStep.values[i].label}'),
        ),
      );
      expect(
        node.flagsCollection.isSelected.name,
        i == 1 ? 'isTrue' : isNot('isTrue'),
        reason: SetupStep.values[i].label,
      );
    }
  });

  testWidgets('finished steps replace their number with a check', (
    tester,
  ) async {
    await pumpWizard(tester, const Size(1100, 800));
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text(Strings.setupNext));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('every stepper row has a spoken label', (tester) async {
    await pumpWizard(tester, const Size(1100, 800));
    for (var i = 0; i < SetupStep.values.length; i++) {
      expect(
        find.bySemanticsLabel(
          RegExp('Step ${i + 1} of 5, ${SetupStep.values[i].label}'),
        ),
        findsOneWidget,
      );
    }
  });
}
