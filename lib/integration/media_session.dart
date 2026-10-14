import 'dart:io';

import 'package:audio_service/audio_service.dart';

import '../player/playback_controller.dart';
import '../strings.dart';

const String mediaSessionId = 'dev.anmitali.altynemel';

Future<MediaSessionHandler> initMediaSession(PlaybackController playback) {
  return AudioService.init(
    builder: () => MediaSessionHandler(playback),
    config: const AudioServiceConfig(
      androidNotificationChannelId: mediaSessionId,
      androidNotificationChannelName: Strings.appName,
    ),
  );
}

class MediaSessionHandler extends BaseAudioHandler {
  MediaSessionHandler(this._playback) {
    _playback.addListener(_publish);
    _publish();
  }

  final PlaybackController _playback;
  String? _publishedTrackId;

  void _publish() {
    final track = _playback.current;
    if (track == null) {
      if (_publishedTrackId != null) {
        _publishedTrackId = null;
        mediaItem.add(null);
      }
      playbackState.add(
        PlaybackState(processingState: AudioProcessingState.idle),
      );
      return;
    }
    if (_publishedTrackId != track.id) {
      _publishedTrackId = track.id;
      final cover = track.coverPath;
      mediaItem.add(
        MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist,
          album: track.album,
          duration: _playback.duration > Duration.zero
              ? _playback.duration
              : track.duration,
          artUri: cover == null ? null : Uri.file(cover),
        ),
      );
    }
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          _playback.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        processingState: AudioProcessingState.ready,
        playing: _playback.isPlaying,
        updatePosition: _playback.position.value,
        speed: 1,
      ),
    );
  }

  @override
  Future<void> play() => _playback.play();

  @override
  Future<void> pause() => _playback.pause();

  @override
  Future<void> stop() => _playback.pause();

  @override
  Future<void> skipToNext() => _playback.next();

  @override
  Future<void> skipToPrevious() => _playback.previous();

  @override
  Future<void> seek(Duration position) async {
    await _playback.seek(position);
    _publish();
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'dbusVolume') {
      final value = extras?['value'];
      if (value is num) {
        await _playback.setVolume((value * 100).round());
      }
    }
  }

  void dispose() => _playback.removeListener(_publish);
}

bool get mediaSessionSupported => Platform.isLinux || Platform.isMacOS;
