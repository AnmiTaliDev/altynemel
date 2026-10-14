import 'dart:ui';

final _token = RegExp(
  r'[MmLlHhVvCcSsAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
);

Path parseSvgPath(String data) {
  final tokens = _token.allMatches(data).map((m) => m.group(0)!).toList();
  final path = Path();
  var index = 0;
  var x = 0.0;
  var y = 0.0;
  var startX = 0.0;
  var startY = 0.0;
  var lastControlX = 0.0;
  var lastControlY = 0.0;
  var lastWasCubic = false;
  String? command;

  double number() => double.parse(tokens[index++]);
  bool isCommand(String token) => RegExp(r'^[A-Za-z]$').hasMatch(token);

  while (index < tokens.length) {
    if (isCommand(tokens[index])) {
      command = tokens[index++];
      if (command == 'Z' || command == 'z') {
        path.close();
        x = startX;
        y = startY;
        lastWasCubic = false;
        continue;
      }
    }
    final relative = command!.toLowerCase() == command;
    final dx = relative ? x : 0.0;
    final dy = relative ? y : 0.0;
    switch (command.toLowerCase()) {
      case 'm':
        x = dx + number();
        y = dy + number();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        command = relative ? 'l' : 'L';
        lastWasCubic = false;
      case 'l':
        x = dx + number();
        y = dy + number();
        path.lineTo(x, y);
        lastWasCubic = false;
      case 'h':
        x = dx + number();
        path.lineTo(x, y);
        lastWasCubic = false;
      case 'v':
        y = dy + number();
        path.lineTo(x, y);
        lastWasCubic = false;
      case 'c':
        final x1 = dx + number();
        final y1 = dy + number();
        final x2 = dx + number();
        final y2 = dy + number();
        x = dx + number();
        y = dy + number();
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastControlX = x2;
        lastControlY = y2;
        lastWasCubic = true;
      case 's':
        final x1 = lastWasCubic ? 2 * x - lastControlX : x;
        final y1 = lastWasCubic ? 2 * y - lastControlY : y;
        final x2 = dx + number();
        final y2 = dy + number();
        x = dx + number();
        y = dy + number();
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastControlX = x2;
        lastControlY = y2;
        lastWasCubic = true;
      case 'a':
        final rx = number();
        final ry = number();
        final rotation = number();
        final largeArc = number() != 0;
        final sweep = number() != 0;
        x = dx + number();
        y = dy + number();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: sweep,
        );
        lastWasCubic = false;
      default:
        throw FormatException('Unsupported path command $command');
    }
  }
  return path;
}
