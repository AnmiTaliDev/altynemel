import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/integration/global_shortcuts.dart';

void main() {
  test('request path follows the portal convention', () {
    expect(
      requestPath(':1.42', 'tok'),
      '/org/freedesktop/portal/desktop/request/1_42/tok',
    );
  });

  test('every shortcut spec has a unique id and a trigger', () {
    final ids = globalShortcutSpecs.map((s) => s.id).toSet();
    expect(ids.length, globalShortcutSpecs.length);
    for (final spec in globalShortcutSpecs) {
      expect(spec.trigger, isNotEmpty);
      expect(spec.description, isNotEmpty);
    }
  });

  test('dispatch runs the matching action and ignores unknown ids', () async {
    final calls = <String>[];
    final shortcuts = GlobalShortcuts(
      actions: {
        'next': () async => calls.add('next'),
        'previous': () async => calls.add('previous'),
      },
    );
    await shortcuts.dispatch('next');
    await shortcuts.dispatch('missing');
    await shortcuts.dispatch('previous');
    expect(calls, ['next', 'previous']);
  });
}
