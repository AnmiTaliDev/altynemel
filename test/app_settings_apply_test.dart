import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/screens/home_screen.dart';
import 'package:altynemel/settings/catalog.dart';

import 'support/test_library.dart';

Future<TestLibrary> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1100, 700),
  void Function(TestLibrary lib)? preset,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final lib = TestLibrary();
  addTearDown(lib.dispose);
  preset?.call(lib);
  await tester.pumpWidget(lib.app());
  await tester.pumpAndSettle();
  return lib;
}

BuildContext homeContext(WidgetTester tester) =>
    tester.element(find.byType(HomeScreen));

void main() {
  testWidgets('text size scales the text of the whole app', (tester) async {
    final lib = await pumpApp(tester);
    expect(MediaQuery.textScalerOf(homeContext(tester)).scale(10), 10);
    lib.settings.setValue(textScalePercent, 150);
    await tester.pumpAndSettle();
    expect(MediaQuery.textScalerOf(homeContext(tester)).scale(10), 15);
  });
}
