import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/themes.dart';

Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  AltynemelThemeId theme = AltynemelThemeId.night,
  Size size = const Size(1100, 700),
  double textScale = 1,
  DesignStyle style = DesignStyle.altynemel,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(theme, style: style),
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: child),
      ),
    ),
  );
}
