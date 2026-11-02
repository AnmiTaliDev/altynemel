import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/integration/android_media_session.dart';

import '../support/test_library.dart';

void main() {
  late TestLibrary lib;
  late AltynemelAudioHandler handler;

  setUp(() {
    lib = TestLibrary();
    handler = AltynemelAudioHandler(lib.playback);
  });

  tearDown(() {
    handler.detach();
    lib.dispose();
  });

  test('starts idle without a media item', () {
    expect(handler.playbackState.value.playing, isFalse);
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.idle,
    );
    expect(handler.mediaItem.value, isNull);
  });

  test('playing a track publishes the item and the playing state', () async {
    await lib.playback.playTracks(lib.library.tracks, 1, title: 'x');
    final state = handler.playbackState.value;
    expect(state.playing, isTrue);
    expect(state.processingState, AudioProcessingState.ready);
    expect(state.controls.map((c) => c.action), [
      MediaAction.skipToPrevious,
      MediaAction.pause,
      MediaAction.skipToNext,
    ]);
    final item = handler.mediaItem.value!;
    expect(item.id, lib.playback.current!.id);
    expect(item.title, lib.playback.current!.title);
  });

  test('media buttons control the playback', () async {
    await lib.playback.playTracks(lib.library.tracks, 0, title: 'x');
    await handler.pause();
    expect(lib.playback.isPlaying, isFalse);
    expect(handler.playbackState.value.playing, isFalse);
    await handler.play();
    expect(lib.playback.isPlaying, isTrue);
    final first = lib.playback.current!.id;
    await handler.skipToNext();
    expect(lib.playback.current!.id, isNot(first));
    await handler.skipToPrevious();
    expect(lib.playback.current!.id, first);
  });

  test('seeking updates the published position', () async {
    await lib.playback.playTracks(lib.library.tracks, 1, title: 'x');
    await handler.seek(const Duration(seconds: 90));
    expect(
      handler.playbackState.value.updatePosition,
      const Duration(seconds: 90),
    );
  });
}
