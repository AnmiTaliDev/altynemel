import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:altynemel/library/track.dart';
import 'package:altynemel/player/playback_controller.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/player/playback_persistence.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/storage/library_database.dart';

import '../support/fake_player.dart';

class Rig {
  Rig({
    this.seconds = 100,
    this.count = 3,
    this.withDatabase = false,
    void Function(AppSettings settings)? preset,
  }) {
    settings = AppSettings();
    preset?.call(settings);
    if (withDatabase) database = LibraryDatabase.inMemory();
    controller = PlaybackController(
      settings: settings,
      persistence: withDatabase ? PlaybackPersistence(database!) : null,
      fileExists: (path) => !missing.contains(path),
      playerFactory: () {
        final fake = FakePlatformPlayer();
        fakes.add(fake);
        return Player(platformPlayer: fake);
      },
    );
    tracks = [
      for (var i = 0; i < count; i++)
        Track(
          id: '$i',
          title: 'Track $i',
          artist: 'A',
          duration: Duration(seconds: seconds),
          path: '/music/$i.mp3',
        ),
    ];
  }

  final int seconds;
  final int count;
  final bool withDatabase;
  final Set<String> missing = {};
  LibraryDatabase? database;
  final List<FakePlatformPlayer> fakes = [];
  late final AppSettings settings;
  late final PlaybackController controller;
  late final List<Track> tracks;

  FakePlatformPlayer get primary => fakes.first;

  Future<void> start([int index = 0]) async {
    await controller.playTracks(tracks, index);
    await settle();
  }

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  Future<void> positionAt(int seconds) async {
    primary.emitPosition(Duration(seconds: seconds));
    await settle();
  }

  void dispose() {
    controller.dispose();
    settings.dispose();
    database?.close();
  }
}

void main() {
  late Rig rig;

  tearDown(() => rig.dispose());

  test('crossfade begins when the remaining time equals its length', () async {
    rig = Rig();
    rig.settings.setCrossfade(true);
    rig.settings.setValue(crossfadeSeconds, 10);
    await rig.start();
    expect(rig.fakes.length, 1);
    await rig.positionAt(85);
    expect(rig.fakes.length, 1);
    await rig.positionAt(91);
    expect(rig.fakes.length, 2);
  });

  test(
    'the default length starts the fade four seconds before the end',
    () async {
      rig = Rig();
      rig.settings.setCrossfade(true);
      await rig.start();
      await rig.positionAt(92);
      expect(rig.fakes.length, 1);
      await rig.positionAt(97);
      expect(rig.fakes.length, 2);
    },
  );

  test('previous restarts only after the configured point', () async {
    rig = Rig();
    rig.settings.setValue(previousRestartSeconds, 8);
    await rig.start(1);
    await rig.positionAt(6);
    await rig.controller.previous();
    await rig.settle();
    expect(rig.controller.current!.id, '0');
  });

  test('previous restarts the track once past the point', () async {
    rig = Rig();
    rig.settings.setValue(previousRestartSeconds, 8);
    await rig.start(1);
    await rig.positionAt(9);
    await rig.controller.previous();
    await rig.settle();
    expect(rig.controller.current!.id, '1');
  });

  test('a zero point always goes back a track', () async {
    rig = Rig();
    rig.settings.setValue(previousRestartSeconds, 0);
    await rig.start(1);
    await rig.positionAt(0);
    await rig.controller.previous();
    await rig.settle();
    expect(rig.controller.current!.id, '0');
  });

  test('the position is saved at the configured interval', () async {
    rig = Rig(withDatabase: true);
    rig.settings.setValue(positionSaveSeconds, 1);
    await rig.start();
    await rig.positionAt(30);
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(PlaybackPersistence(rig.database!).load()!.positionMs, 30000);
  });

  test('a longer interval does not save the position yet', () async {
    rig = Rig(withDatabase: true);
    await rig.start();
    await rig.positionAt(30);
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(PlaybackPersistence(rig.database!).load()!.positionMs, 0);
  });

  test('a linear crossfade ramps both players straight', () async {
    rig = Rig();
    rig.settings.setCrossfade(true);
    rig.settings.setValue(crossfadeCurve, CrossfadeCurve.linear);
    rig.settings.setValue(crossfadeSeconds, 1);
    await rig.start();
    await rig.positionAt(99);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final outgoing = rig.fakes.first.state.volume;
    final incoming = rig.fakes[1].state.volume;
    expect(outgoing + incoming, closeTo(70, 5));
  });

  test('an equal power crossfade keeps the combined power steady', () async {
    rig = Rig();
    rig.settings.setCrossfade(true);
    rig.settings.setValue(crossfadeSeconds, 1);
    await rig.start();
    await rig.positionAt(99);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final outgoing = rig.fakes.first.state.volume;
    final incoming = rig.fakes[1].state.volume;
    expect(outgoing * outgoing + incoming * incoming, closeTo(70 * 70, 400));
  });

  test('a coarse crossfade step delays the first volume update', () async {
    rig = Rig();
    rig.settings.setCrossfade(true);
    rig.settings.setValue(crossfadeStepMs, 200);
    await rig.start();
    await rig.positionAt(97);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(rig.fakes[1].state.volume, 0);
  });

  test('a fine crossfade step updates the volume right away', () async {
    rig = Rig();
    rig.settings.setCrossfade(true);
    rig.settings.setValue(crossfadeStepMs, 10);
    await rig.start();
    await rig.positionAt(97);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(rig.fakes[1].state.volume, greaterThan(0));
  });

  test('a missing file is skipped by default', () async {
    rig = Rig();
    rig.missing.add('/music/1.mp3');
    await rig.start();
    await rig.controller.next();
    await rig.settle();
    expect(rig.controller.current!.id, '2');
    expect(rig.controller.isPlaying, isTrue);
  });

  test('with skipping off a missing file stops playback on it', () async {
    rig = Rig();
    rig.missing.add('/music/1.mp3');
    rig.settings.setValue(skipUnavailableTracks, false);
    await rig.start();
    await rig.controller.next();
    await rig.settle();
    expect(rig.controller.current!.id, '1');
    expect(rig.controller.isPlaying, isFalse);
  });

  test('the starting volume comes from the setting', () {
    rig = Rig(preset: (settings) => settings.setValue(defaultVolume, 35));
    expect(rig.controller.volume, 35);
  });

  test('a starting volume of zero unmutes to a sane level', () async {
    rig = Rig(preset: (settings) => settings.setValue(defaultVolume, 0));
    expect(rig.controller.volume, 0);
    await rig.controller.toggleMute();
    expect(rig.controller.volume, 70);
  });

  test('the volume never exceeds the maximum', () async {
    rig = Rig(preset: (settings) => settings.setValue(maximumVolume, 60));
    await rig.controller.setVolume(90);
    expect(rig.controller.volume, 60);
    await rig.controller.setVolume(20);
    expect(rig.controller.volume, 20);
  });

  test('without a limit the volume reaches 100', () async {
    rig = Rig();
    await rig.controller.setVolume(100);
    expect(rig.controller.volume, 100);
  });

  Future<Rig> savedRig({required bool resume}) async {
    final first = Rig(withDatabase: true);
    await first.start(1);
    first.controller.persist();
    final second = Rig(
      preset: (settings) => settings.setValue(resumeOnLaunch, resume),
    );
    second.database = first.database;
    final restored = PlaybackController(
      settings: second.settings,
      persistence: PlaybackPersistence(first.database!),
      fileExists: (_) => true,
      playerFactory: () {
        final fake = FakePlatformPlayer();
        second.fakes.add(fake);
        return Player(platformPlayer: fake);
      },
    );
    await restored.restore((id) => first.tracks[int.parse(id)]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(restored.current!.id, '1');
    final playing = restored.isPlaying;
    restored.dispose();
    second.settings.dispose();
    second.controller.dispose();
    first.controller.dispose();
    first.settings.dispose();
    first.database!.close();
    rig = Rig();
    expect(playing, resume);
    return rig;
  }

  test('a restored queue stays paused by default', () async {
    await savedRig(resume: false);
  });

  test('a restored queue plays when resuming on launch is on', () async {
    await savedRig(resume: true);
  });

  test('the speed is applied when the player is created', () {
    rig = Rig(preset: (settings) => settings.setValue(playbackSpeed, 1.5));
    expect(rig.primary.state.rate, 1.5);
  });

  test('changing the speed reaches the running player', () async {
    rig = Rig();
    await rig.start();
    expect(rig.primary.state.rate, 1);
    rig.settings.setValue(playbackSpeed, 0.75);
    await rig.settle();
    expect(rig.primary.state.rate, 0.75);
  });

  test('the fade player gets the same speed', () async {
    rig = Rig(preset: (settings) => settings.setValue(playbackSpeed, 1.25));
    rig.settings.setCrossfade(true);
    await rig.start();
    await rig.positionAt(97);
    expect(rig.fakes[1].state.rate, 1.25);
  });

  test(
    'play on a track whose file is missing reports it and does not play',
    () async {
      rig = Rig(count: 1);
      rig.missing.add('/music/0.mp3');
      await rig.controller.playTracks(rig.tracks, 0);
      await rig.settle();
      expect(rig.controller.isPlaying, isFalse);
      expect(rig.controller.error, 'File not found: Track 0');
      await rig.controller.play();
      await rig.settle();
      expect(rig.controller.isPlaying, isFalse);
      expect(rig.controller.error, 'File not found: Track 0');
    },
  );

  test('play loads the track once its file is back', () async {
    rig = Rig(count: 1);
    rig.missing.add('/music/0.mp3');
    await rig.controller.playTracks(rig.tracks, 0);
    await rig.settle();
    rig.missing.clear();
    await rig.controller.play();
    await rig.settle();
    expect(rig.controller.isPlaying, isTrue);
    expect(rig.controller.error, isNull);
  });

  test('play resumes a loaded track without reloading it', () async {
    rig = Rig();
    await rig.start();
    await rig.controller.pause();
    final opens = rig.primary.log.where((e) => e == 'open').length;
    await rig.controller.play();
    expect(rig.controller.isPlaying, isTrue);
    expect(rig.primary.log.where((e) => e == 'open').length, opens);
  });

  test('restoring a queue whose first file is missing stays paused', () async {
    final first = Rig(withDatabase: true);
    await first.start(0);
    first.controller.persist();
    final second = Rig(count: 3);
    second.missing.add('/music/0.mp3');
    final restored = PlaybackController(
      settings: second.settings,
      persistence: PlaybackPersistence(first.database!),
      fileExists: (path) => !second.missing.contains(path),
      playerFactory: () {
        final fake = FakePlatformPlayer();
        second.fakes.add(fake);
        return Player(platformPlayer: fake);
      },
    );
    await restored.restore((id) => first.tracks[int.parse(id)]);
    await second.settle();
    expect(restored.isPlaying, isFalse);
    expect(restored.current!.id, '1');
    restored.dispose();
    second.dispose();
    first.dispose();
    rig = Rig();
  });
}
