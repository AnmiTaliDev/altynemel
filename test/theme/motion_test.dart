import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/app_settings_scope.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/theme/motion.dart';

Future<Duration> measure(
  WidgetTester tester, {
  AppSettings? settings,
  bool disable = false,
}) async {
  late Duration result;
  Widget child = MediaQuery(
    data: MediaQueryData(disableAnimations: disable),
    child: Builder(
      builder: (context) {
        result = motionDuration(context, motionQuick);
        return const SizedBox();
      },
    ),
  );
  if (settings != null) {
    child = AppSettingsScope(settings: settings, child: child);
  }
  await tester.pumpWidget(
    Directionality(textDirection: TextDirection.ltr, child: child),
  );
  return result;
}

void main() {
  testWidgets('without settings the duration is unchanged', (tester) async {
    expect(await measure(tester), motionQuick);
  });

  testWidgets('the default speed keeps the duration', (tester) async {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    expect(await measure(tester, settings: settings), motionQuick);
  });

  testWidgets('a faster setting shortens the duration', (tester) async {
    final settings = AppSettings()..setValue(animationSpeedPercent, 200);
    addTearDown(settings.dispose);
    expect(
      await measure(tester, settings: settings),
      const Duration(milliseconds: 80),
    );
  });

  testWidgets('a slower setting lengthens the duration', (tester) async {
    final settings = AppSettings()..setValue(animationSpeedPercent, 50);
    addTearDown(settings.dispose);
    expect(
      await measure(tester, settings: settings),
      const Duration(milliseconds: 320),
    );
  });

  testWidgets('disabled animations win over the speed', (tester) async {
    final settings = AppSettings()..setValue(animationSpeedPercent, 400);
    addTearDown(settings.dispose);
    expect(
      await measure(tester, settings: settings, disable: true),
      Duration.zero,
    );
  });
}
