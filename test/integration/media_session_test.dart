import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:altynemel/integration/media_session.dart';
import 'package:altynemel/library/track.dart';
import 'package:altynemel/player/playback_controller.dart';
import 'package:altynemel/settings/app_settings.dart';

import '../support/fake_player.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late AppSettings settings;
  late PlaybackController playback;
  late MediaSessionHandler handler;
  late List<Track> tracks;

  setUp(() {
    settings = AppSettings();
    playback = PlaybackController(
      settings: settings,
      fileExists: (_) => true,
      playerFactory: () => Player(platformPlayer: FakePlatformPlayer()),
    );
    handler = MediaSessionHandler(playback);
    tracks = [
      for (var i = 0; i < 3; i++)
        Track(
          id: '$i',
          title: i == 0 ? 'Балбырауын' : 'Track $i',
          artist: i == 0 ? 'Құрманғазы' : 'Artist',
          album: 'Album',
          duration: const Duration(minutes: 3),
          path: '/music/$i.mp3',
          coverPath: i == 0 ? '/covers/a.jpg' : null,
        ),
    ];
  });

  tearDown(() async {
    handler.dispose();
    playback.dispose();
    settings.dispose();
  });

  test('starts idle with no media item', () {
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.idle,
    );
    expect(handler.mediaItem.value, isNull);
  });

  test('publishes the current track and playing state', () async {
    await playback.playTracks(tracks, 0);
    await settle();
    final item = handler.mediaItem.value!;
    expect(item.title, 'Балбырауын');
    expect(item.artist, 'Құрманғазы');
    expect(item.album, 'Album');
    expect(item.duration, const Duration(minutes: 3));
    expect(item.artUri, Uri.file('/covers/a.jpg'));
    final state = handler.playbackState.value;
    expect(state.playing, isTrue);
    expect(state.processingState, AudioProcessingState.ready);
    expect(state.controls, contains(MediaControl.pause));
    expect(state.controls, contains(MediaControl.skipToNext));
    expect(state.controls, contains(MediaControl.skipToPrevious));
    expect(state.systemActions, contains(MediaAction.seek));
  });

  test('controls switch to play when paused', () async {
    await playback.playTracks(tracks, 0);
    await handler.pause();
    await settle();
    expect(playback.isPlaying, isFalse);
    expect(handler.playbackState.value.playing, isFalse);
    expect(handler.playbackState.value.controls, contains(MediaControl.play));
  });

  test('play, next and previous drive the player', () async {
    await playback.playTracks(tracks, 0);
    await handler.pause();
    await handler.play();
    expect(playback.isPlaying, isTrue);
    await handler.skipToNext();
    await settle();
    expect(playback.current!.id, '1');
    expect(handler.mediaItem.value!.title, 'Track 1');
    expect(handler.mediaItem.value!.artUri, isNull);
    await handler.skipToPrevious();
    expect(playback.current!.id, '0');
  });

  test('seek moves the position and is published', () async {
    await playback.playTracks(tracks, 0);
    await handler.seek(const Duration(seconds: 42));
    expect(playback.position.value, const Duration(seconds: 42));
    expect(
      handler.playbackState.value.updatePosition,
      const Duration(seconds: 42),
    );
  });

  test('the volume sent over D-Bus is applied in percent', () async {
    await handler.customAction('dbusVolume', {'value': 0.35});
    expect(playback.volume, 35);
    await handler.customAction('dbusVolume', {'value': 2.0});
    expect(playback.volume, 100);
    await handler.customAction('unknown', {'value': 0.5});
    expect(playback.volume, 100);
  });
}
