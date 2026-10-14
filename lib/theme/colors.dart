import 'package:flutter/material.dart';

class AltynemelColors extends ThemeExtension<AltynemelColors> {
  const AltynemelColors({
    required this.ground,
    required this.surface,
    required this.surfaceHigh,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.inkMuted,
    required this.inkDisabled,
    required this.accent,
    required this.onAccent,
    required this.ok,
    required this.alert,
  });

  final Color ground;
  final Color surface;
  final Color surfaceHigh;
  final Color line;
  final Color lineStrong;

  Color get surfaceEdge =>
      lineStrong == contrast.lineStrong ? lineStrong : line;
  final Color ink;
  final Color inkMuted;
  final Color inkDisabled;
  final Color accent;
  final Color onAccent;
  final Color ok;
  final Color alert;

  static const night = AltynemelColors(
    ground: Color(0xFF111315),
    surface: Color(0xFF181B1E),
    surfaceHigh: Color(0xFF22262A),
    line: Color(0xFF2C3136),
    lineStrong: Color(0xFF7B848D),
    ink: Color(0xFFF1F3F2),
    inkMuted: Color(0xFFA7B0B6),
    inkDisabled: Color(0xFF5A6168),
    accent: Color(0xFF7FD6B1),
    onAccent: Color(0xFF0B1411),
    ok: Color(0xFF5CC8E8),
    alert: Color(0xFFFF9A6B),
  );

  static const day = AltynemelColors(
    ground: Color(0xFFF6F7F5),
    surface: Color(0xFFECEFEC),
    surfaceHigh: Color(0xFFDEE3DF),
    line: Color(0xFFD5DBD7),
    lineStrong: Color(0xFF66707A),
    ink: Color(0xFF111315),
    inkMuted: Color(0xFF4A545C),
    inkDisabled: Color(0xFF9AA3A9),
    accent: Color(0xFF0E7A5F),
    onAccent: Color(0xFFFFFFFF),
    ok: Color(0xFF0A6685),
    alert: Color(0xFFA62D08),
  );

  static const contrast = AltynemelColors(
    ground: Color(0xFF000000),
    surface: Color(0xFF0B0B0B),
    surfaceHigh: Color(0xFF1C1C1C),
    line: Color(0xFF8C8C8C),
    lineStrong: Color(0xFFFFFFFF),
    ink: Color(0xFFFFFFFF),
    inkMuted: Color(0xFFEDEDED),
    inkDisabled: Color(0xFF7A7A7A),
    accent: Color(0xFFFFD166),
    onAccent: Color(0xFF000000),
    ok: Color(0xFF7FD3F0),
    alert: Color(0xFFFFA466),
  );

  static AltynemelColors of(BuildContext context) =>
      Theme.of(context).extension<AltynemelColors>()!;

  @override
  AltynemelColors copyWith({
    Color? ground,
    Color? surface,
    Color? surfaceHigh,
    Color? line,
    Color? lineStrong,
    Color? ink,
    Color? inkMuted,
    Color? inkDisabled,
    Color? accent,
    Color? onAccent,
    Color? ok,
    Color? alert,
  }) {
    return AltynemelColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkDisabled: inkDisabled ?? this.inkDisabled,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      ok: ok ?? this.ok,
      alert: alert ?? this.alert,
    );
  }

  @override
  AltynemelColors lerp(ThemeExtension<AltynemelColors>? other, double t) {
    if (other is! AltynemelColors) return this;
    return AltynemelColors(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkDisabled: Color.lerp(inkDisabled, other.inkDisabled, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
    );
  }
}
