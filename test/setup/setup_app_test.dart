import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/setup/setup_wizard.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';
import 'package:altynemel/theme/style.dart';

import '../support/test_library.dart';

Future<TestLibrary> pumpApp(
  WidgetTester tester, {
  bool setUp = false,
  Size size = const Size(1100, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  lib.settings.setSetupCompleted(setUp);
  await tester.pumpWidget(lib.app());
  await tester.pumpAndSettle();
  return lib;
}

void main() {
  testWidgets('a fresh install opens the wizard instead of the library', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(SetupWizard), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('a set up app opens the library', (tester) async {
    await pumpApp(tester, setUp: true);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SetupWizard), findsNothing);
  });

  testWidgets('finishing the wizard shows the library', (tester) async {
    await pumpApp(tester);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text(Strings.setupNext).last);
      await tester.pumpAndSettle();
    }
    expect(find.text(Strings.setupFinishTitle), findsOneWidget);
    await tester.tap(find.text(Strings.setupFinish));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SetupWizard), findsNothing);
  });

  testWidgets('skipping the whole setup shows the library', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text(Strings.setupSkipAll));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('the style chosen in the wizard restyles the wizard itself', (
    tester,
  ) async {
    final lib = await pumpApp(tester);
    await tester.tap(find.text(Strings.setupNext).last);
    await tester.pumpAndSettle();
    BuildContext context() => tester.element(find.byType(SetupWizard));
    expect(AltynemelStyle.of(context()).material, isFalse);
    await tester.tap(find.text(Strings.setupStyleMaterial));
    await tester.pumpAndSettle();
    expect(lib.settings.valueOf(designStyle), DesignStyle.material);
    expect(AltynemelStyle.of(context()).material, isTrue);
  });

  testWidgets('the wizard works on a phone sized window', (tester) async {
    await pumpApp(tester, size: const Size(360, 720));
    expect(find.byType(SetupWizard), findsOneWidget);
    await tester.tap(find.text(Strings.setupNext));
    await tester.pumpAndSettle();
    expect(find.text(Strings.setupAppearanceTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings can run the setup again', (tester) async {
    final lib = await pumpApp(tester, setUp: true, size: const Size(1100, 900));
    await tester.tap(
      find.descendant(
        of: find.byType(Sidebar),
        matching: find.bySemanticsLabel('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(Strings.setupRunAgain),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(Strings.setupRunAgain));
    await tester.pump();
    await tester.tap(find.text(Strings.setupRunAgain));
    await tester.pumpAndSettle();
    expect(lib.settings.setupCompleted, isFalse);
    expect(find.byType(SetupWizard), findsOneWidget);
    expect(find.text(Strings.setupWelcomeTitle), findsOneWidget);
  });
}
