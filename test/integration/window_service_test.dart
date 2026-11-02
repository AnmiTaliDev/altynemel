import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/integration/window_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maximized follows the window events', () {
    final service = WindowService();
    expect(service.maximized.value, isFalse);
    service.onWindowMaximize();
    expect(service.maximized.value, isTrue);
    service.onWindowUnmaximize();
    expect(service.maximized.value, isFalse);
    service.dispose();
  });
}
