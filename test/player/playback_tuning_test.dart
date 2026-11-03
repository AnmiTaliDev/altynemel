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
  Rig({this.seconds = 100, this.count = 3, this.withDatabase = false}) {
    settings = AppSettings();
    if (withDatabase) database = LibraryDatabase.inMemory();
    controller = PlaybackController(
      settings: settings,
      persistence: withDatabase ? PlaybackPersistence(database!) : null,
      fileExists: (_) => true,
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
}
