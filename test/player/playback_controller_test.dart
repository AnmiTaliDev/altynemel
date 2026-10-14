import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:altynemel/library/track.dart';
import 'package:altynemel/player/playback_controller.dart';
import 'package:altynemel/player/playback_persistence.dart';
import 'package:altynemel/player/repeat_setting.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/storage/library_database.dart';

import '../support/audio_fixtures.dart';

Future<void> until(bool Function() condition, {int seconds = 8}) async {
  final limit = DateTime.now().add(Duration(seconds: seconds));
  while (!condition() && DateTime.now().isBefore(limit)) {
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  expect(condition(), isTrue, reason: 'condition not reached in ${seconds}s');
}

void main() {
  late Directory dir;
  late AppSettings settings;
  late LibraryDatabase db;
  late PlaybackController controller;
  late List<Track> tracks;

  setUpAll(() {
    MediaKit.ensureInitialized();
    NativePlayer.test = true;
  });

  List<Track> makeTracks(List<double> lengths) {
    return [
      for (var i = 0; i < lengths.length; i++)
        Track(
          id: '$i',
          title: 'Track $i',
          artist: 'A',
          duration: Duration(milliseconds: (lengths[i] * 1000).round()),
          path: writeFile(
            dir,
            't$i.wav',
            wavBytes(seconds: lengths[i], frequency: 300.0 + 100 * i),
          ).path,
        ),
    ];
  }

  PlaybackController build(List<double> lengths) {
    tracks = makeTracks(lengths);
    return controller = PlaybackController(
      settings: settings,
      persistence: PlaybackPersistence(db),
    );
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('altynemel_play_');
    settings = AppSettings();
    db = LibraryDatabase.inMemory();
  });

  tearDown(() async {
    controller.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    settings.dispose();
    db.close();
    dir.deleteSync(recursive: true);
  });

  test('play starts the track and position advances', () async {
    build([5]);
    await controller.playTracks(tracks, 0, title: 'Library');
    expect(controller.current!.id, '0');
    await until(() => controller.isPlaying);
    await until(
      () => controller.position.value > const Duration(milliseconds: 300),
    );
    expect(controller.sourceTitle, 'Library');
  });

  test('pause stops position and play resumes', () async {
    build([6]);
    await controller.playTracks(tracks, 0);
    await until(
      () => controller.position.value > const Duration(milliseconds: 300),
    );
    await controller.pause();
    expect(controller.isPlaying, isFalse);
    final frozen = controller.position.value;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(
      (controller.position.value - frozen).inMilliseconds.abs(),
      lessThan(150),
    );
    await controller.play();
    await until(
      () =>
          controller.position.value >
          frozen + const Duration(milliseconds: 300),
    );
  });

  test('seek moves the position', () async {
    build([8]);
    await controller.playTracks(tracks, 0);
    await until(() => controller.isPlaying);
    await controller.seek(const Duration(seconds: 5));
    await until(() => controller.position.value >= const Duration(seconds: 5));
    expect(controller.position.value, lessThan(const Duration(seconds: 7)));
  });

  test('volume is applied and mute restores the previous level', () async {
    build([4]);
    await controller.playTracks(tracks, 0);
    await controller.setVolume(40);
    expect(controller.volume, 40);
    await controller.toggleMute();
    expect(controller.volume, 0);
    expect(controller.isMuted, isTrue);
    await controller.toggleMute();
    expect(controller.volume, 40);
    await controller.setVolume(500);
    expect(controller.volume, 100);
  });

  test('next and previous move through the queue', () async {
    build([5, 5, 5]);
    await controller.playTracks(tracks, 0);
    await controller.next();
    expect(controller.current!.id, '1');
    await controller.next();
    expect(controller.current!.id, '2');
    await controller.next();
    expect(controller.current!.id, '2');
    await until(() => controller.position.value < const Duration(seconds: 1));
    await controller.previous();
    expect(controller.current!.id, '1');
  });

  test('previous restarts the track after three seconds', () async {
    build([10, 10]);
    await controller.playTracks(tracks, 1);
    await controller.seek(const Duration(seconds: 6));
    await until(() => controller.position.value >= const Duration(seconds: 6));
    await controller.previous();
    expect(controller.current!.id, '1');
    await until(() => controller.position.value < const Duration(seconds: 2));
  });

  test('a track advances to the next one on its own', () async {
    build([1.2, 3]);
    await controller.playTracks(tracks, 0);
    await until(() => controller.current!.id == '1');
    await until(() => controller.isPlaying);
  });

  test('the queue ends after the last track with repeat off', () async {
    build([0.8]);
    await controller.playTracks(tracks, 0);
    await until(
      () => !controller.isPlaying && controller.position.value == Duration.zero,
      seconds: 6,
    );
    expect(controller.current!.id, '0');
    await controller.play();
    await until(() => controller.isPlaying);
  });

  test('repeat one loops the same track', () async {
    build([1, 4]);
    await controller.setRepeat(RepeatSetting.one);
    await controller.playTracks(tracks, 0);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    expect(controller.current!.id, '0');
    expect(controller.isPlaying, isTrue);
  });

  test('repeat all wraps to the first track', () async {
    build([1, 1]);
    await controller.setRepeat(RepeatSetting.all);
    await controller.playTracks(tracks, 1);
    await until(() => controller.current!.id == '0');
    await until(() => controller.isPlaying);
  });

  test('shuffle changes the queue order but keeps the current track', () async {
    build([5, 5, 5, 5, 5, 5]);
    await controller.playTracks(tracks, 2);
    await controller.setShuffle(true);
    expect(controller.current!.id, '2');
    expect(controller.queuePosition, 0);
    expect(controller.queueTracks.map((t) => t.id).toSet().length, 6);
    await controller.setShuffle(false);
    expect(controller.queueTracks.map((t) => t.id), [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
    ]);
    expect(controller.current!.id, '2');
  });

  test('a missing file is skipped', () async {
    build([3, 3, 3]);
    File(tracks[1].path!).deleteSync();
    await controller.playTracks(tracks, 0);
    await controller.next();
    expect(controller.current!.id, '2');
  });

  test(
    'when every file is missing playback stops without looping forever',
    () async {
      build([1, 1]);
      for (final t in tracks) {
        File(t.path!).deleteSync();
      }
      await controller.playTracks(tracks, 0);
      expect(controller.isPlaying, isFalse);
      expect(controller.error, isNotNull);
    },
  );

  test('queue and position are restored in a new controller, paused', () async {
    build([10, 10, 10]);
    await controller.playTracks(tracks, 1);
    await controller.seek(const Duration(seconds: 4));
    await until(() => controller.position.value >= const Duration(seconds: 4));
    await controller.setVolume(55);
    await controller.pause();
    controller.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final restored = PlaybackController(
      settings: settings,
      persistence: PlaybackPersistence(db),
    );
    controller = restored;
    await restored.restore((id) => tracks.firstWhere((t) => t.id == id));
    expect(restored.current!.id, '1');
    expect(restored.isPlaying, isFalse);
    expect(restored.volume, 55);
    await until(() => restored.position.value >= const Duration(seconds: 3));
    expect(restored.queueTracks.length, 3);
  });

  test(
    'crossfade switches to the next track and ends on the new one',
    () async {
      settings.setCrossfade(true);
      build([9, 9]);
      await controller.playTracks(tracks, 0);
      await until(() => controller.current!.id == '1', seconds: 12);
      await until(() => controller.isPlaying);
      await until(
        () => controller.position.value > const Duration(milliseconds: 200),
      );
      expect(controller.volume, 70);
    },
  );

  test('gapless setting off still advances', () async {
    settings.setGapless(false);
    build([1, 3]);
    await controller.playTracks(tracks, 0);
    await until(() => controller.current!.id == '1');
    await until(() => controller.isPlaying);
  });

  test('play next puts a track after the current one', () async {
    build([5, 5, 5]);
    await controller.playTracks(tracks.sublist(0, 2), 0);
    await controller.playNext(tracks[2]);
    expect(controller.queueTracks.map((t) => t.id), ['0', '2', '1']);
    await controller.enqueue(tracks[2]);
    expect(controller.queueTracks.length, 4);
  });
}
