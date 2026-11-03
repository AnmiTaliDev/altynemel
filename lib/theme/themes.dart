import 'package:flutter/material.dart';

import '../settings/choices.dart';
import 'accents.dart';
import 'colors.dart';
import 'text_styles.dart';

enum AltynemelThemeId { night, day, contrast }

AltynemelColors colorsFor(AltynemelThemeId id) {
  switch (id) {
    case AltynemelThemeId.night:
      return AltynemelColors.night;
    case AltynemelThemeId.day:
      return AltynemelColors.day;
    case AltynemelThemeId.contrast:
      return AltynemelColors.contrast;
  }
}

ThemeData buildTheme(
  AltynemelThemeId id, {
  AccentChoice accent = AccentChoice.theme,
}) {
  final pair = accentPair(accent, id);
  final base = colorsFor(id);
  final colors = pair == null
      ? base
      : base.copyWith(accent: pair.$1, onAccent: pair.$2);
  final text = AltynemelTextStyles.from(colors);
  final brightness = id == AltynemelThemeId.day
      ? Brightness.light
      : Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: colors.ink,
    onPrimary: colors.ground,
    secondary: colors.accent,
    onSecondary: colors.onAccent,
    error: colors.alert,
    onError: colors.ground,
    surface: colors.ground,
    onSurface: colors.ink,
    outline: colors.lineStrong,
    outlineVariant: colors.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.ground,
    canvasColor: colors.ground,
    fontFamily: AltynemelTextStyles.family,
    focusColor: colors.accent,
    hoverColor: colors.surfaceHigh,
    splashFactory: NoSplash.splashFactory,
    dividerColor: colors.line,
    textTheme: TextTheme(
      bodyLarge: text.bodyLg,
      bodyMedium: text.body,
      bodySmall: text.caption,
      labelLarge: text.bodyStrong,
      labelMedium: text.label,
      labelSmall: text.label,
      titleLarge: text.displayMd,
      headlineMedium: text.displayLg,
      displayLarge: text.displayXl,
    ),
    extensions: [colors, text],
  );
}
