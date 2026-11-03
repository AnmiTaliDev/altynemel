import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:altynemel/library/track.dart';
import 'package:altynemel/player/playback_controller.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';

import '../support/fake_player.dart';

class Rig {
  Rig({this.seconds = 100, this.count = 3}) {
    settings = AppSettings();
    controller = PlaybackController(
      settings: settings,
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
}
