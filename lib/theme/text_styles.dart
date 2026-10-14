import 'package:flutter/material.dart';

import 'colors.dart';

class AltynemelTextStyles extends ThemeExtension<AltynemelTextStyles> {
  const AltynemelTextStyles({
    required this.displayXl,
    required this.displayLg,
    required this.displayMd,
    required this.bodyLg,
    required this.body,
    required this.bodyStrong,
    required this.caption,
    required this.label,
    required this.time,
  });

  final TextStyle displayXl;
  final TextStyle displayLg;
  final TextStyle displayMd;
  final TextStyle bodyLg;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle caption;
  final TextStyle label;
  final TextStyle time;

  static const String family = 'Onest';

  static TextStyle _style({
    required Color color,
    required double size,
    required double lineHeight,
    required int weight,
    double letterSpacingEm = 0,
    List<FontFeature> features = const [],
  }) {
    return TextStyle(
      fontFamily: family,
      color: color,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight == 500 ? FontWeight.w500 : FontWeight.w400,
      fontVariations: [FontVariation.weight(weight.toDouble())],
      letterSpacing: letterSpacingEm * size,
      fontFeatures: features,
    );
  }

  factory AltynemelTextStyles.from(AltynemelColors colors) {
    final ink = colors.ink;
    return AltynemelTextStyles(
      displayXl: _style(
        color: ink,
        size: 56,
        lineHeight: 56,
        weight: 500,
        letterSpacingEm: -0.04,
      ),
      displayLg: _style(
        color: ink,
        size: 40,
        lineHeight: 44,
        weight: 500,
        letterSpacingEm: -0.035,
      ),
      displayMd: _style(
        color: ink,
        size: 24,
        lineHeight: 30,
        weight: 500,
        letterSpacingEm: -0.02,
      ),
      bodyLg: _style(color: ink, size: 17, lineHeight: 26, weight: 400),
      body: _style(color: ink, size: 15, lineHeight: 22, weight: 400),
      bodyStrong: _style(color: ink, size: 15, lineHeight: 22, weight: 500),
      caption: _style(color: ink, size: 13, lineHeight: 18, weight: 400),
      label: _style(color: ink, size: 13, lineHeight: 16, weight: 500),
      time: _style(
        color: ink,
        size: 13,
        lineHeight: 16,
        weight: 400,
        features: [const FontFeature.tabularFigures()],
      ),
    );
  }

  static AltynemelTextStyles of(BuildContext context) =>
      Theme.of(context).extension<AltynemelTextStyles>()!;

  @override
  AltynemelTextStyles copyWith({
    TextStyle? displayXl,
    TextStyle? displayLg,
    TextStyle? displayMd,
    TextStyle? bodyLg,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? caption,
    TextStyle? label,
    TextStyle? time,
  }) {
    return AltynemelTextStyles(
      displayXl: displayXl ?? this.displayXl,
      displayLg: displayLg ?? this.displayLg,
      displayMd: displayMd ?? this.displayMd,
      bodyLg: bodyLg ?? this.bodyLg,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      caption: caption ?? this.caption,
      label: label ?? this.label,
      time: time ?? this.time,
    );
  }

  @override
  AltynemelTextStyles lerp(
    ThemeExtension<AltynemelTextStyles>? other,
    double t,
  ) {
    if (other is! AltynemelTextStyles) return this;
    return AltynemelTextStyles(
      displayXl: TextStyle.lerp(displayXl, other.displayXl, t)!,
      displayLg: TextStyle.lerp(displayLg, other.displayLg, t)!,
      displayMd: TextStyle.lerp(displayMd, other.displayMd, t)!,
      bodyLg: TextStyle.lerp(bodyLg, other.bodyLg, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      time: TextStyle.lerp(time, other.time, t)!,
    );
  }
}
