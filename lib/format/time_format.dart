String formatTime(Duration duration) {
  final total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$ss';
  }
  return '$minutes:$ss';
}

String _unit(int value, String name) =>
    value == 1 ? '1 $name' : '$value ${name}s';

String spokenDuration(Duration duration) {
  final total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  final parts = <String>[
    if (hours > 0) _unit(hours, 'hour'),
    if (minutes > 0) _unit(minutes, 'minute'),
    if (seconds > 0) _unit(seconds, 'second'),
  ];
  return parts.isEmpty ? '0 seconds' : parts.join(' ');
}

String spokenProgress(Duration position, Duration duration) {
  return '${spokenDuration(position)} of ${spokenDuration(duration)}';
}

String shortDuration(Duration duration) {
  final total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  if (hours > 0) return '$hours h $minutes min';
  return '$minutes min $seconds sec';
}
