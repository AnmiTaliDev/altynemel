import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/setup/steps/library_step.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';

Future<AppSettings> pumpStep(
  WidgetTester tester, {
  Future<void> Function()? onChooseFolder,
  Future<bool> Function()? onRequestAccess,
  Size size = const Size(700, 900),
}) async {
  final settings = AppSettings();
  addTearDown(settings.dispose);
  await pumpThemed(
    tester,
    SingleChildScrollView(
      child: LibraryStep(
        settings: settings,
        onChooseFolder: onChooseFolder,
        onRequestAccess: onRequestAccess,
      ),
    ),
    size: size,
  );
  return settings;
}

void main() {
  testWidgets('without a folder it asks to choose one', (tester) async {
    await pumpStep(tester, onChooseFolder: () async {});
    expect(find.text(Strings.setupLibraryNone), findsOneWidget);
    expect(find.text(Strings.setupLibraryChoose), findsOneWidget);
    expect(find.text(Strings.setupLibraryLater), findsOneWidget);
  });

  testWidgets('choosing a folder calls the callback and shows the path', (
    tester,
  ) async {
    late AppSettings settings;
    var calls = 0;
    settings = await pumpStep(
      tester,
      onChooseFolder: () async {
        calls++;
        settings.setLibraryFolder('/home/me/Music');
      },
    );
    await tester.tap(find.text(Strings.setupLibraryChoose));
    await tester.pump();
    expect(calls, 1);
    expect(find.text('Selected: /home/me/Music'), findsOneWidget);
    expect(find.text(Strings.setupLibraryChange), findsOneWidget);
    expect(find.text(Strings.setupLibraryChoose), findsNothing);
  });

  testWidgets('an unavailable picker is explained', (tester) async {
    await pumpStep(tester);
    expect(find.text(Strings.unavailableInBuild), findsOneWidget);
    expect(find.text(Strings.setupLibraryChoose), findsNothing);
  });

  testWidgets('the access card appears only when the platform needs it', (
    tester,
  ) async {
    await pumpStep(tester, onChooseFolder: () async {});
    expect(find.text(Strings.setupAccessAllow), findsNothing);
    await pumpStep(
      tester,
      onChooseFolder: () async {},
      onRequestAccess: () async => true,
    );
    expect(find.text(Strings.setupAccessAllow), findsWidgets);
  });

  testWidgets('a granted permission is confirmed', (tester) async {
    await pumpStep(
      tester,
      onChooseFolder: () async {},
      onRequestAccess: () async => true,
    );
    await tester.tap(find.text(Strings.setupAccessAllow).last);
    await tester.pump();
    expect(find.text(Strings.setupAccessGranted), findsOneWidget);
  });

  testWidgets('a denied permission is explained', (tester) async {
    await pumpStep(
      tester,
      onChooseFolder: () async {},
      onRequestAccess: () async => false,
    );
    await tester.tap(find.text(Strings.setupAccessAllow).last);
    await tester.pump();
    expect(find.text(Strings.setupAccessDenied), findsOneWidget);
  });

  testWidgets('it lays out on a phone', (tester) async {
    await pumpStep(
      tester,
      onChooseFolder: () async {},
      onRequestAccess: () async => true,
      size: const Size(360, 800),
    );
    expect(tester.takeException(), isNull);
  });
}
