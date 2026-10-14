import 'package:flutter/widgets.dart';

import 'icon_data.dart';

class AltynemelIcon extends StatelessWidget {
  const AltynemelIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.filled = false,
    this.strokeWidth,
  });

  final IconId icon;
  final double size;
  final Color? color;
  final bool filled;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _IconPainter(
          icon: icon,
          color: resolved,
          filled: filled,
          strokeWidth: strokeWidth ?? iconShapes[icon]!.strokeWidth,
        ),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter({
    required this.icon,
    required this.color,
    required this.filled,
    required this.strokeWidth,
  });

  final IconId icon;
  final Color color;
  final bool filled;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);
    final path = iconPath(icon);
    if (filled) {
      canvas.drawPath(path, Paint()..color = color);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_IconPainter old) {
    return old.icon != icon ||
        old.color != color ||
        old.filled != filled ||
        old.strokeWidth != strokeWidth;
  }
}
