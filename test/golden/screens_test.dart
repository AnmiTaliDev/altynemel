import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/demo/demo_screen.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/app_settings_scope.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/fonts.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  SidebarDestination? destination,
  AltynemelThemeId theme,
) async {
  tester.view.physicalSize = const Size(1100, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final settings = AppSettings();
  addTearDown(settings.dispose);
  await tester.pumpWidget(
    AppSettingsScope(
      settings: settings,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(theme),
        home: Scaffold(body: DemoScreen(initialDestination: destination)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadOnest);

  final screens = <String, SidebarDestination?>{
    'playlist': null,
    'library': SidebarDestination.library,
    'queue': SidebarDestination.queue,
    'settings': SidebarDestination.settings,
  };

  for (final screen in screens.entries) {
    for (final theme in AltynemelThemeId.values) {
      testWidgets('${screen.key} in ${theme.name}', (tester) async {
        await pumpScreen(tester, screen.value, theme);
        await expectLater(
          find.byType(Scaffold).first,
          matchesGoldenFile('goldens/${screen.key}_${theme.name}.png'),
        );
      });
    }
  }
}
