import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/player_bar.dart';
import 'package:altynemel/player/repeat_setting.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/theme/material_palette.dart';
import 'package:altynemel/theme/themes.dart';

import '../support/pump.dart';

Future<void> pumpBar(
  WidgetTester tester, {
  DesignStyle style = DesignStyle.material,
}) {
  return pumpThemed(
    tester,
    Align(
      alignment: Alignment.bottomCenter,
      child: PlayerBar(
        title: 'fading memories',
        artist: 'june lu',
        liked: false,
        onToggleLike: () {},
        isPlaying: false,
        shuffle: false,
        repeat: RepeatSetting.off,
        onShuffle: () {},
        onPrevious: () {},
        onPlayPause: () {},
        onNext: () {},
        onRepeat: () {},
        position: Duration.zero,
        duration: const Duration(minutes: 3),
        onSeek: (_) {},
        volume: 50,
        onVolume: (_) {},
        onQueue: () {},
      ),
    ),
    size: const Size(1100, 400),
    style: style,
  );
}

BoxDecoration barDecoration(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(PlayerBar),
          matching: find.byType(Container),
        )
        .first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  final scheme = materialScheme(AltynemelThemeId.night, AccentChoice.theme);

  testWidgets('the Material 3 bar has the container color and no top line', (
    tester,
  ) async {
    await pumpBar(tester);
    final decoration = barDecoration(tester);
    expect(decoration.color, scheme.surfaceContainer);
    expect(decoration.border, isNull);
  });

  testWidgets('the original bar keeps its top border', (tester) async {
    await pumpBar(tester, style: DesignStyle.altynemel);
    expect(barDecoration(tester).border, isNotNull);
  });
}
