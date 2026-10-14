import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/format/time_format.dart';

void main() {
  test('formats minutes and seconds', () {
    expect(formatTime(const Duration(seconds: 147)), '2:27');
    expect(formatTime(Duration.zero), '0:00');
  });

  test('formats hours for long tracks', () {
    expect(
      formatTime(const Duration(hours: 1, minutes: 4, seconds: 12)),
      '1:04:12',
    );
  });

  test('speaks durations in words', () {
    expect(
      spokenDuration(const Duration(minutes: 2, seconds: 47)),
      '2 minutes 47 seconds',
    );
    expect(
      spokenDuration(const Duration(minutes: 1, seconds: 1)),
      '1 minute 1 second',
    );
    expect(spokenDuration(const Duration(minutes: 3)), '3 minutes');
    expect(spokenDuration(Duration.zero), '0 seconds');
  });

  test('speaks progress', () {
    expect(
      spokenProgress(
        const Duration(minutes: 2, seconds: 47),
        const Duration(minutes: 4, seconds: 12),
      ),
      '2 minutes 47 seconds of 4 minutes 12 seconds',
    );
  });

  test('short duration for summaries', () {
    expect(
      shortDuration(const Duration(minutes: 2, seconds: 27)),
      '2 min 27 sec',
    );
  });
}
