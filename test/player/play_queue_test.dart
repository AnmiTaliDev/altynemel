import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/track.dart';
import 'package:altynemel/player/play_queue.dart';
import 'package:altynemel/player/repeat_setting.dart';

List<Track> tracks(int n) {
  return [
    for (var i = 0; i < n; i++)
      Track(
        id: '$i',
        title: 't$i',
        artist: 'a',
        duration: const Duration(minutes: 3),
        path: '/m/$i.mp3',
      ),
  ];
}

List<String> ids(Iterable<Track> list) => [for (final t in list) t.id];

PlayQueue queue({int seed = 1}) => PlayQueue(random: Random(seed));

void main() {
  test('plays in natural order and stops at the end with repeat off', () {
    final q = queue()..load(tracks(3));
    expect(q.current!.id, '0');
    expect(q.advance(auto: true)!.id, '1');
    expect(q.advance(auto: true)!.id, '2');
    expect(q.peekNext(auto: true), isNull);
    expect(q.advance(auto: true), isNull);
    expect(q.current!.id, '2');
  });

  test('start index is honoured', () {
    final q = queue()..load(tracks(5), start: 3);
    expect(q.current!.id, '3');
    expect(q.advance(auto: false)!.id, '4');
  });

  test('repeat all wraps around', () {
    final q = queue()
      ..setRepeat(RepeatSetting.all)
      ..load(tracks(2), start: 1);
    expect(q.peekNext(auto: true)!.id, '0');
    expect(q.advance(auto: true)!.id, '0');
    expect(q.advance(auto: true)!.id, '1');
  });

  test('repeat one repeats on auto advance but manual next moves on', () {
    final q = queue()
      ..setRepeat(RepeatSetting.one)
      ..load(tracks(3));
    expect(q.advance(auto: true)!.id, '0');
    expect(q.peekNext(auto: true)!.id, '0');
    expect(q.advance(auto: false)!.id, '1');
  });

  test('back moves to the previous track, wraps only with repeat all', () {
    final q = queue()..load(tracks(3), start: 1);
    expect(q.back()!.id, '0');
    expect(q.back(), isNull);
    q.setRepeat(RepeatSetting.all);
    expect(q.back()!.id, '2');
  });

  test('shuffle keeps the current track first and visits every track once', () {
    final q = queue(seed: 7)..load(tracks(20), start: 5);
    q.setShuffle(true);
    expect(q.current!.id, '5');
    expect(q.position, 0);
    final seen = <String>[q.current!.id];
    while (true) {
      final next = q.advance(auto: true);
      if (next == null) break;
      seen.add(next.id);
    }
    expect(seen.length, 20);
    expect(seen.toSet().length, 20);
    expect(ids(q.ordered), seen);
  });

  test('shuffle off restores natural order around the current track', () {
    final q = queue(seed: 3)..load(tracks(6));
    q.setShuffle(true);
    q.advance(auto: true);
    final current = q.current!.id;
    q.setShuffle(false);
    expect(q.current!.id, current);
    expect(ids(q.ordered), ['0', '1', '2', '3', '4', '5']);
    expect(q.position, int.parse(current));
  });

  test('load while shuffle is on starts at the chosen track', () {
    final q = queue(seed: 2)..setShuffle(true);
    q.load(tracks(10), start: 4);
    expect(q.current!.id, '4');
    expect(q.ordered.length, 10);
  });

  test(
    'repeat all with shuffle reshuffles each cycle without repeating at the seam',
    () {
      final q = queue(seed: 11)
        ..setRepeat(RepeatSetting.all)
        ..load(tracks(8));
      q.setShuffle(true);
      for (var cycle = 0; cycle < 20; cycle++) {
        final seen = <String>{q.current!.id};
        var last = q.current!.id;
        for (var i = 0; i < 7; i++) {
          final preview = q.peekNext(auto: true)!;
          final next = q.advance(auto: true)!;
          expect(next.id, preview.id);
          seen.add(next.id);
          last = next.id;
        }
        expect(seen.length, 8);
        final peek = q.peekNext(auto: true)!;
        expect(peek.id, isNot(last));
        expect(q.advance(auto: true)!.id, peek.id);
      }
    },
  );

  test('play next inserts after the current track, enqueue appends', () {
    final all = tracks(4);
    final q = queue()..load(all.sublist(0, 3));
    q.playNext(all[3]);
    expect(ids(q.ordered), ['0', '3', '1', '2']);
    final extra = Track(
      id: 'x',
      title: 'x',
      artist: 'a',
      duration: Duration.zero,
    );
    q.enqueue(extra);
    expect(ids(q.ordered), ['0', '3', '1', '2', 'x']);
    expect(q.advance(auto: false)!.id, '3');
  });

  test('play next on an empty queue makes the track current', () {
    final q = queue();
    q.playNext(tracks(1).first);
    expect(q.current!.id, '0');
  });

  test('empty queue is safe', () {
    final q = queue();
    expect(q.current, isNull);
    expect(q.advance(auto: true), isNull);
    expect(q.back(), isNull);
    expect(q.peekNext(auto: true), isNull);
    q.setShuffle(true);
    expect(q.ordered, isEmpty);
  });

  test('jumpTo validates the position', () {
    final q = queue()..load(tracks(3));
    expect(q.jumpTo(2), isTrue);
    expect(q.current!.id, '2');
    expect(q.jumpTo(3), isFalse);
    expect(q.jumpTo(-1), isFalse);
  });

  test('state survives a JSON round trip, including shuffle order', () {
    final all = tracks(6);
    final q = queue(seed: 5)..load(all, start: 2);
    q.setShuffle(true);
    q.setRepeat(RepeatSetting.all);
    q.advance(auto: true);
    final json = q.toJson();
    final restored = queue();
    restored.restore(json, (id) => all.firstWhere((t) => t.id == id));
    expect(ids(restored.ordered), ids(q.ordered));
    expect(restored.current!.id, q.current!.id);
    expect(restored.position, q.position);
    expect(restored.shuffle, isTrue);
    expect(restored.repeat, RepeatSetting.all);
  });

  test(
    'restore drops tracks that no longer exist and keeps a valid position',
    () {
      final all = tracks(5);
      final q = queue()..load(all, start: 3);
      final json = q.toJson();
      final restored = queue();
      restored.restore(
        json,
        (id) => id == '1' ? null : all.firstWhere((t) => t.id == id),
      );
      expect(ids(restored.ordered), ['0', '2', '3', '4']);
      expect(restored.current!.id, '3');
    },
  );

  test('restore when the current track is gone falls back to a nearby one', () {
    final all = tracks(3);
    final q = queue()..load(all, start: 1);
    final restored = queue();
    restored.restore(
      q.toJson(),
      (id) => id == '1' ? null : all.firstWhere((t) => t.id == id),
    );
    expect(restored.current, isNotNull);
    expect(restored.ordered.length, 2);
  });

  test('restore of an empty or damaged state yields an empty queue', () {
    final restored = queue();
    restored.restore({}, (id) => null);
    expect(restored.current, isNull);
    restored.restore({
      'ids': ['9'],
      'order': [0],
      'position': 0,
    }, (id) => null);
    expect(restored.current, isNull);
  });
}
