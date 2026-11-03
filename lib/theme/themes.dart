import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../settings/choices.dart';
import 'accents.dart';
import 'colors.dart';
import 'material_palette.dart';
import 'style.dart';
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

AltynemelThemeId resolveThemeId(ThemeChoice choice, Brightness platform) {
  return switch (choice) {
    ThemeChoice.night => AltynemelThemeId.night,
    ThemeChoice.day => AltynemelThemeId.day,
    ThemeChoice.contrast => AltynemelThemeId.contrast,
    ThemeChoice.system =>
      platform == Brightness.dark
          ? AltynemelThemeId.night
          : AltynemelThemeId.day,
  };
}

ThemeData buildTheme(
  AltynemelThemeId id, {
  AccentChoice accent = AccentChoice.theme,
  DesignStyle style = DesignStyle.altynemel,
}) {
  if (style == DesignStyle.material) return _buildMaterialTheme(id, accent);
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
    extensions: [colors, text, AltynemelStyle.original],
  );
}

ThemeData _buildMaterialTheme(AltynemelThemeId id, AccentChoice accent) {
  final scheme = materialScheme(id, accent);
  final colors = materialColors(scheme);
  final text = AltynemelTextStyles.material(colors);
  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.ground,
    canvasColor: colors.ground,
    fontFamily: AltynemelTextStyles.family,
    focusColor: colors.accent,
    hoverColor: colors.ink.withValues(alpha: 0.08),
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
    extensions: [
      colors,
      text,
      AltynemelStyle(design: DesignStyle.material, scheme: scheme),
    ],
  );
}
