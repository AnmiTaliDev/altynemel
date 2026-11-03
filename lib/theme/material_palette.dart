import 'package:flutter/material.dart';

import '../settings/choices.dart';
import 'colors.dart';
import 'themes.dart';

const Map<AccentChoice, Color> materialSeeds = {
  AccentChoice.theme: Color(0xFF6750A4),
  AccentChoice.mint: Color(0xFF1B9E77),
  AccentChoice.sky: Color(0xFF1E88E5),
  AccentChoice.amber: Color(0xFFF2A900),
  AccentChoice.rose: Color(0xFFD81B60),
  AccentChoice.violet: Color(0xFF7C4DFF),
};

ColorScheme materialScheme(AltynemelThemeId id, AccentChoice accent) {
  return ColorScheme.fromSeed(
    seedColor: materialSeeds[accent]!,
    brightness: id == AltynemelThemeId.day ? Brightness.light : Brightness.dark,
    contrastLevel: id == AltynemelThemeId.contrast ? 1.0 : 0.0,
  );
}

AltynemelColors materialColors(ColorScheme scheme) {
  return AltynemelColors(
    ground: scheme.surface,
    surface: scheme.surfaceContainer,
    surfaceHigh: scheme.surfaceContainerHigh,
    line: scheme.outlineVariant,
    lineStrong: scheme.outline,
    ink: scheme.onSurface,
    inkMuted: scheme.onSurfaceVariant,
    inkDisabled: Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.38),
      scheme.surface,
    ),
    accent: scheme.primary,
    onAccent: scheme.onPrimary,
    ok: scheme.tertiary,
    alert: scheme.error,
  );
}
