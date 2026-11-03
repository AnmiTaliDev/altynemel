import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/advanced_settings_screen.dart';
import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/screens/settings_screen.dart';

import '../support/test_library.dart';

void main() {
  testWidgets('settings open the advanced page and back returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(
      lib.wrap(
        const HomeScreen(initialDestination: SidebarDestination.settings),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Open advanced settings'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Open advanced settings'));
    await tester.pump();
    await tester.tap(find.text('Open advanced settings'));
    await tester.pumpAndSettle();
    expect(find.byType(AdvancedSettingsScreen), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('the system back button leaves the advanced page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lib = TestLibrary();
    addTearDown(lib.dispose);
    await tester.pumpWidget(
      lib.wrap(
        const HomeScreen(initialDestination: SidebarDestination.settings),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Open advanced settings'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Open advanced settings'));
    await tester.pump();
    await tester.tap(find.text('Open advanced settings'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
