import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:altynemel/integration/mpris.dart';
import 'package:altynemel/library/track.dart';
import 'package:altynemel/player/playback_controller.dart';
import 'package:altynemel/player/repeat_setting.dart';
import 'package:altynemel/settings/app_settings.dart';

import '../support/fake_player.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

DBusMethodCall call(String interface, String name, [List<DBusValue>? values]) {
  return DBusMethodCall(
    sender: ':1.1',
    interface: interface,
    name: name,
    values: values ?? const [],
  );
}

Future<DBusValue> read(
  MprisService service,
  String interface,
  String name,
) async {
  final response = await service.getProperty(interface, name);
  return (response as DBusGetPropertyResponse).values[0].asVariant();
}

void main() {
  late AppSettings settings;
  late PlaybackController playback;
  late MprisService service;
  late List<Track> tracks;
  late List<String> calls;

  setUp(() {
    calls = [];
    settings = AppSettings();
    playback = PlaybackController(
      settings: settings,
      fileExists: (_) => true,
      playerFactory: () => Player(platformPlayer: FakePlatformPlayer()),
    );
    service = MprisService(
      playback: playback,
      onRaise: () async => calls.add('raise'),
      onQuit: () async => calls.add('quit'),
    );
    tracks = [
      for (var i = 0; i < 3; i++)
        Track(
          id: 'id-$i',
          title: i == 0 ? 'Балбырауын' : 'Track $i',
          artist: i == 0 ? 'Құрманғазы' : 'Artist',
          album: i == 2 ? null : 'Album',
          duration: const Duration(minutes: 3),
          path: '/music/$i.mp3',
          coverPath: i == 0 ? '/covers/a.jpg' : null,
        ),
    ];
  });

  tearDown(() {
    playback.dispose();
    settings.dispose();
  });

  test(
    'the root interface names the desktop entry and allows raise and quit',
    () async {
      expect(
        (await read(service, mprisRootInterface, 'DesktopEntry')).asString(),
        'dev.anmitali.altynemel',
      );
      expect(
        (await read(service, mprisRootInterface, 'CanRaise')).asBoolean(),
        isTrue,
      );
      expect(
        (await read(service, mprisRootInterface, 'CanQuit')).asBoolean(),
        isTrue,
      );
      expect(
        (await read(service, mprisRootInterface, 'Identity')).asString(),
        'Altynemel',
      );
    },
  );

  test('Raise and Quit call the window callbacks', () async {
    await service.handleMethodCall(call(mprisRootInterface, 'Raise'));
    await service.handleMethodCall(call(mprisRootInterface, 'Quit'));
    expect(calls, ['raise', 'quit']);
  });

  test('an idle player is stopped with no track', () async {
    expect(
      (await read(service, mprisPlayerInterface, 'PlaybackStatus')).asString(),
      'Stopped',
    );
    final metadata = (await read(
      service,
      mprisPlayerInterface,
      'Metadata',
    )).asStringVariantDict();
    expect(metadata.keys, ['mpris:trackid']);
    expect(metadata['mpris:trackid']!.asObjectPath(), mprisNoTrack);
    expect(
      (await read(service, mprisPlayerInterface, 'CanPlay')).asBoolean(),
      isFalse,
    );
  });

  test('metadata carries the track and the cover only when present', () async {
    await playback.playTracks(tracks, 0);
    await settle();
    var metadata = (await read(
      service,
      mprisPlayerInterface,
      'Metadata',
    )).asStringVariantDict();
    expect(metadata['xesam:title']!.asString(), 'Балбырауын');
    expect(metadata['xesam:artist']!.asStringArray().toList(), ['Құрманғазы']);
    expect(metadata['xesam:album']!.asString(), 'Album');
    expect(
      metadata['mpris:artUrl']!.asString(),
      Uri.file('/covers/a.jpg').toString(),
    );
    expect(metadata['mpris:trackid']!.asObjectPath(), mprisTrackPath('id-0'));
    expect(metadata['mpris:length']!.asInt64(), greaterThan(0));
    await playback.next();
    await settle();
    metadata = (await read(
      service,
      mprisPlayerInterface,
      'Metadata',
    )).asStringVariantDict();
    expect(metadata.containsKey('mpris:artUrl'), isFalse);
    await playback.next();
    await settle();
    metadata = (await read(
      service,
      mprisPlayerInterface,
      'Metadata',
    )).asStringVariantDict();
    expect(metadata.containsKey('xesam:album'), isFalse);
  });

  test('playback status follows play and pause', () async {
    await playback.playTracks(tracks, 0);
    await settle();
    expect(
      (await read(service, mprisPlayerInterface, 'PlaybackStatus')).asString(),
      'Playing',
    );
    await service.handleMethodCall(call(mprisPlayerInterface, 'PlayPause'));
    expect(
      (await read(service, mprisPlayerInterface, 'PlaybackStatus')).asString(),
      'Paused',
    );
    await service.handleMethodCall(call(mprisPlayerInterface, 'Play'));
    expect(playback.isPlaying, isTrue);
    await service.handleMethodCall(call(mprisPlayerInterface, 'Pause'));
    expect(playback.isPlaying, isFalse);
  });

  test('Next and Previous drive the queue', () async {
    await playback.playTracks(tracks, 0);
    await service.handleMethodCall(call(mprisPlayerInterface, 'Next'));
    expect(playback.current!.id, 'id-1');
    await service.handleMethodCall(call(mprisPlayerInterface, 'Previous'));
    expect(playback.current!.id, 'id-0');
  });

  test('Seek and SetPosition move the position', () async {
    await playback.playTracks(tracks, 0);
    await service.handleMethodCall(
      call(mprisPlayerInterface, 'Seek', [const DBusInt64(10000000)]),
    );
    expect(playback.position.value, const Duration(seconds: 10));
    await service.handleMethodCall(
      call(mprisPlayerInterface, 'SetPosition', [
        mprisTrackPath('id-0'),
        const DBusInt64(30000000),
      ]),
    );
    expect(playback.position.value, const Duration(seconds: 30));
    await service.handleMethodCall(
      call(mprisPlayerInterface, 'SetPosition', [
        mprisTrackPath('other'),
        const DBusInt64(1000000),
      ]),
    );
    expect(playback.position.value, const Duration(seconds: 30));
    expect(
      (await read(service, mprisPlayerInterface, 'Position')).asInt64(),
      30000000,
    );
  });

  test('volume, shuffle and loop can be set', () async {
    await playback.playTracks(tracks, 0);
    await service.setProperty(
      mprisPlayerInterface,
      'Volume',
      const DBusDouble(0.4),
    );
    expect(playback.volume, 40);
    await service.setProperty(
      mprisPlayerInterface,
      'Shuffle',
      const DBusBoolean(true),
    );
    expect(playback.shuffle, isTrue);
    await service.setProperty(
      mprisPlayerInterface,
      'LoopStatus',
      const DBusString('Track'),
    );
    expect(playback.repeat, RepeatSetting.one);
    await service.setProperty(
      mprisPlayerInterface,
      'LoopStatus',
      const DBusString('Playlist'),
    );
    expect(playback.repeat, RepeatSetting.all);
    final bad = await service.setProperty(
      mprisPlayerInterface,
      'LoopStatus',
      const DBusString('Nope'),
    );
    expect(bad, isA<DBusMethodErrorResponse>());
    final readOnly = await service.setProperty(
      mprisPlayerInterface,
      'CanSeek',
      const DBusBoolean(false),
    );
    expect(readOnly, isA<DBusMethodErrorResponse>());
  });

  test('unknown methods, interfaces and properties are errors', () async {
    expect(
      await service.handleMethodCall(call(mprisPlayerInterface, 'Missing')),
      isA<DBusMethodErrorResponse>(),
    );
    expect(
      await service.handleMethodCall(call('org.example.Other', 'Play')),
      isA<DBusMethodErrorResponse>(),
    );
    expect(
      await service.getProperty(mprisPlayerInterface, 'Missing'),
      isA<DBusMethodErrorResponse>(),
    );
    expect(
      await service.getAllProperties('org.example.Other'),
      isA<DBusMethodErrorResponse>(),
    );
  });

  test('all properties include the position on the player interface', () async {
    final response =
        await service.getAllProperties(mprisPlayerInterface)
            as DBusGetAllPropertiesResponse;
    expect(
      response.values[0].asStringVariantDict().keys,
      containsAll(['Position', 'Metadata', 'PlaybackStatus', 'Volume']),
    );
  });

  test('track paths are valid object paths and unique per id', () {
    expect(mprisTrackPath('a/b c'), isNot(mprisTrackPath('a_b_c')));
    expect(
      mprisTrackPath('x').value,
      startsWith('/dev/anmitali/altynemel/track/'),
    );
  });

  test('loop status maps both ways', () {
    for (final repeat in RepeatSetting.values) {
      expect(mprisRepeat(mprisLoopStatus(repeat)), repeat);
    }
    expect(mprisRepeat('x'), isNull);
  });

  test('the service describes both interfaces', () {
    final names = service.introspect().map((i) => i.name).toList();
    expect(names, [mprisRootInterface, mprisPlayerInterface]);
  });
}
