import 'package:flutter/material.dart';

import '../settings/choices.dart';

class AltynemelStyle extends ThemeExtension<AltynemelStyle> {
  const AltynemelStyle({required this.design, this.scheme});

  final DesignStyle design;
  final ColorScheme? scheme;

  bool get material => design == DesignStyle.material && scheme != null;

  static const original = AltynemelStyle(design: DesignStyle.altynemel);

  static AltynemelStyle of(BuildContext context) =>
      Theme.of(context).extension<AltynemelStyle>() ?? original;

  @override
  AltynemelStyle copyWith({DesignStyle? design, ColorScheme? scheme}) {
    return AltynemelStyle(
      design: design ?? this.design,
      scheme: scheme ?? this.scheme,
    );
  }

  @override
  AltynemelStyle lerp(ThemeExtension<AltynemelStyle>? other, double t) {
    if (other is! AltynemelStyle) return this;
    final a = scheme;
    final b = other.scheme;
    return AltynemelStyle(
      design: t < 0.5 ? design : other.design,
      scheme: a == null || b == null
          ? (t < 0.5 ? a : b)
          : ColorScheme.lerp(a, b, t),
    );
  }
}
