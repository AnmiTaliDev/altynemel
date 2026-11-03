import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/transport.dart';
import 'package:altynemel/player/repeat_setting.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpTransport(
  WidgetTester tester,
  TransportVariant variant, {
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Center(
      child: Transport(
        variant: variant,
        isPlaying: false,
        shuffle: false,
        repeat: RepeatSetting.off,
        onShuffle: () {},
        onPrevious: () {},
        onPlayPause: () {},
        onNext: () {},
        onRepeat: () {},
      ),
    ),
    size: const Size(500, 200),
    style: style,
  );
}

BoxDecoration playDecoration(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.bySemanticsLabel('Play'),
          matching: find.byType(Container),
        )
        .first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the large play button is a primary rounded square', (
    tester,
  ) async {
    await pumpTransport(tester, TransportVariant.accent);
    final decoration = playDecoration(tester);
    expect(decoration.color, scheme.primary);
    expect(decoration.borderRadius, BorderRadius.circular(28));
    expect(tester.getSize(find.bySemanticsLabel('Play')), const Size(72, 72));
  });

  testWidgets('the bar play button is a primary circle', (tester) async {
    await pumpTransport(tester, TransportVariant.bar);
    final decoration = playDecoration(tester);
    expect(decoration.color, scheme.primary);
    expect(tester.getSize(find.bySemanticsLabel('Play')), const Size(48, 48));
  });

  testWidgets('the original style keeps the light play button', (tester) async {
    await pumpTransport(
      tester,
      TransportVariant.bar,
      style: DesignStyle.altynemel,
    );
    expect(playDecoration(tester).color, isNot(scheme.primary));
  });
}
