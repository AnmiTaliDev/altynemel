import 'dart:ui';

import '../settings/choices.dart';
import 'themes.dart';

const _onDark = {
  AccentChoice.mint: (Color(0xFF7FD6B1), Color(0xFF0B1411)),
  AccentChoice.sky: (Color(0xFF7FB8F0), Color(0xFF0A1220)),
  AccentChoice.amber: (Color(0xFFF2C14E), Color(0xFF1A1305)),
  AccentChoice.rose: (Color(0xFFF28AA8), Color(0xFF200A12)),
  AccentChoice.violet: (Color(0xFFB59CF5), Color(0xFF120B22)),
};

const _onLight = {
  AccentChoice.mint: (Color(0xFF0E7A5F), Color(0xFFFFFFFF)),
  AccentChoice.sky: (Color(0xFF1565C0), Color(0xFFFFFFFF)),
  AccentChoice.amber: (Color(0xFF8A5A00), Color(0xFFFFFFFF)),
  AccentChoice.rose: (Color(0xFFB3294E), Color(0xFFFFFFFF)),
  AccentChoice.violet: (Color(0xFF6A3FC4), Color(0xFFFFFFFF)),
};

(Color accent, Color onAccent)? accentPair(
  AccentChoice choice,
  AltynemelThemeId theme,
) {
  if (choice == AccentChoice.theme) return null;
  return theme == AltynemelThemeId.day ? _onLight[choice] : _onDark[choice];
}
