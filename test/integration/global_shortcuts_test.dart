import 'dart:async';

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

  test('a failed call leaves no unhandled timeout behind', () async {
    final uncaught = <Object>[];
    await runZonedGuarded(() async {
      final pending = Future<int>.delayed(
        const Duration(milliseconds: 30),
        () => throw TimeoutException('no response'),
      );
      await expectLater(
        awaitAfterCall<int>(Future<void>.error(StateError('denied')), pending),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }, (error, stack) => uncaught.add(error));
    expect(uncaught, isEmpty);
  });

  test('the pending response is returned after a successful call', () async {
    final value = await awaitAfterCall<int>(
      Future<void>.value(),
      Future<int>.delayed(const Duration(milliseconds: 10), () => 7),
    );
    expect(value, 7);
  });

  test(
    'a late timeout still reaches the caller after a successful call',
    () async {
      await expectLater(
        awaitAfterCall<int>(
          Future<void>.value(),
          Future<int>.delayed(
            const Duration(milliseconds: 10),
            () => throw TimeoutException('no response'),
          ),
        ),
        throwsA(isA<TimeoutException>()),
      );
    },
  );
}
