import 'package:audio_service/audio_service.dart';

import '../player/playback_controller.dart';

const Duration _seekJump = Duration(seconds: 2);

class AltynemelAudioHandler extends BaseAudioHandler with SeekHandler {
  AltynemelAudioHandler(this.playback) {
    _lastPosition = playback.position.value;
    playback.addListener(_onPlayback);
    playback.position.addListener(_onPosition);
    _publish();
  }

  final PlaybackController playback;
  late Duration _lastPosition;
  String? _itemId;
  Duration _itemDuration = Duration.zero;

  void detach() {
    playback.removeListener(_onPlayback);
    playback.position.removeListener(_onPosition);
  }

  void _onPlayback() {
    _publishItem();
    _publish();
  }

  void _onPosition() {
    final value = playback.position.value;
    final jumped = (value - _lastPosition).abs() > _seekJump;
    _lastPosition = value;
    if (jumped) _publish();
  }

  void _publishItem() {
    final track = playback.current;
    if (track == null) {
      if (_itemId != null) {
        _itemId = null;
        mediaItem.add(null);
      }
      return;
    }
    final length = playback.duration > Duration.zero
        ? playback.duration
        : track.duration;
    if (track.id == _itemId && length == _itemDuration) return;
    _itemId = track.id;
    _itemDuration = length;
    final cover = track.coverPath;
    mediaItem.add(
      MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist.trim().isEmpty ? null : track.artist,
        album: track.album,
        duration: length,
        artUri: cover == null ? null : Uri.file(cover),
      ),
    );
  }

  void _publish() {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playback.isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: playback.hasTrack
            ? AudioProcessingState.ready
            : AudioProcessingState.idle,
        playing: playback.isPlaying,
        updatePosition: playback.position.value,
      ),
    );
  }

  @override
  Future<void> play() => playback.play();

  @override
  Future<void> pause() => playback.pause();

  @override
  Future<void> stop() => playback.pause();

  @override
  Future<void> skipToNext() => playback.next();

  @override
  Future<void> skipToPrevious() => playback.previous();

  @override
  Future<void> seek(Duration position) => playback.seek(position);
}

Future<void> startAndroidMediaSession(PlaybackController playback) {
  return AudioService.init(
    builder: () => AltynemelAudioHandler(playback),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'dev.anmitali.altynemel.playback',
      androidNotificationChannelName: 'Playback',
    ),
  );
}
