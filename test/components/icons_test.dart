import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_data.dart';

void main() {
  test('every icon id has a shape', () {
    for (final id in IconId.values) {
      expect(iconShapes.containsKey(id), isTrue, reason: id.name);
    }
  });

  test('every icon path stays on the 24 px grid', () {
    for (final id in IconId.values) {
      final bounds = iconPath(id).getBounds();
      expect(bounds.isEmpty && id != IconId.more, isFalse, reason: id.name);
      expect(bounds.left, greaterThanOrEqualTo(0), reason: id.name);
      expect(bounds.top, greaterThanOrEqualTo(0), reason: id.name);
      expect(bounds.right, lessThanOrEqualTo(24), reason: id.name);
      expect(bounds.bottom, lessThanOrEqualTo(24), reason: id.name);
    }
  });

  test('play path bounds match the source geometry', () {
    final bounds = iconPath(IconId.play).getBounds();
    expect(bounds.left, closeTo(8, 0.001));
    expect(bounds.right, closeTo(18.5, 0.001));
    expect(bounds.top, closeTo(5.5, 0.001));
    expect(bounds.bottom, closeTo(18.5, 0.001));
  });

  test('search circle spans the expected box', () {
    final bounds = iconPath(IconId.search).getBounds();
    expect(bounds.left, closeTo(5, 0.1));
    expect(bounds.right, closeTo(20, 0.1));
  });
}
