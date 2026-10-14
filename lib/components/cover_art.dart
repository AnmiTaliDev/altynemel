import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import 'svg_path.dart';

enum CoverShape { square, arch }

class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    required this.size,
    this.image,
    this.albumName,
    this.shape = CoverShape.square,
    this.radius = radiusArt,
  });

  final double size;
  final ImageProvider? image;
  final String? albumName;
  final CoverShape shape;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final width = size;
    final height = shape == CoverShape.arch ? size * 1.25 : size;
    final borderRadius = shape == CoverShape.arch
        ? const BorderRadius.vertical(top: Radius.circular(radiusPill))
        : BorderRadius.circular(radius);
    final placeholder = CustomPaint(
      size: Size(width, height),
      painter: _DunePainter(
        background: colors.surfaceHigh,
        ridge: colors.inkMuted,
        ridgeStrong: colors.lineStrong,
      ),
    );
    final label = image != null && albumName != null
        ? Strings.coverOf(albumName!)
        : Strings.coverUnavailable;
    return Semantics(
      image: true,
      label: label,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image == null)
                placeholder
              else
                Image(
                  image: image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(color: colors.line, width: borderWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DunePainter extends CustomPainter {
  _DunePainter({
    required this.background,
    required this.ridge,
    required this.ridgeStrong,
  });

  final Color background;
  final Color ridge;
  final Color ridgeStrong;

  static final _first = parseSvgPath('M0 88C22 74 40 84 62 72S90 62 100 66');
  static final _second = parseSvgPath('M0 102C24 92 46 100 68 90S92 84 100 86');

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final scale = size.width / 100 > size.height / 125
        ? size.width / 100
        : size.height / 125;
    final dx = (size.width - 100 * scale) / 2;
    final dy = (size.height - 125 * scale) / 2;
    final matrix = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    Paint stroke(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_first.transform(matrix.storage), stroke(ridge));
    canvas.drawPath(_second.transform(matrix.storage), stroke(ridgeStrong));
  }

  @override
  bool shouldRepaint(_DunePainter old) {
    return old.background != background ||
        old.ridge != ridge ||
        old.ridgeStrong != ridgeStrong;
  }
}
