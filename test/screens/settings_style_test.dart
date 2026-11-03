import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/choice_row.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/strings.dart';
import 'package:altynemel/theme/style.dart';

import '../support/test_library.dart';

void main() {
  testWidgets('the settings page switches the design style live', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(lib.app());
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Sidebar),
        matching: find.bySemanticsLabel('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    BuildContext context() => tester.element(find.byType(HomeScreen));
    expect(AltynemelStyle.of(context()).material, isFalse);
    await tester.tap(
      find.descendant(
        of: find.byType(ChoiceRow<DesignStyle>),
        matching: find.text('Material 3'),
      ),
    );
    await tester.pumpAndSettle();
    expect(lib.settings.valueOf(designStyle), DesignStyle.material);
    expect(AltynemelStyle.of(context()).material, isTrue);
    await tester.tap(
      find.descendant(
        of: find.byType(ChoiceRow<DesignStyle>),
        matching: find.text('Altynemel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(AltynemelStyle.of(context()).material, isFalse);
    expect(find.text(Strings.setupStyleLabel), findsOneWidget);
  });
}
