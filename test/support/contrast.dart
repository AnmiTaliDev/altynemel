import 'dart:math';
import 'dart:ui';

double _channel(double value) {
  return value <= 0.03928
      ? value / 12.92
      : pow((value + 0.055) / 1.055, 2.4).toDouble();
}

double luminance(Color color) {
  return 0.2126 * _channel(color.r) +
      0.7152 * _channel(color.g) +
      0.0722 * _channel(color.b);
}

double contrastRatio(Color a, Color b) {
  final la = luminance(a);
  final lb = luminance(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}
