import 'dart:ui';

import 'svg_path.dart';

enum IconId {
  play,
  pause,
  prev,
  next,
  shuffle,
  repeat,
  heart,
  queue,
  search,
  library,
  download,
  more,
  check,
  close,
  volume,
  down,
  alert,
  playing,
}

class IconShape {
  const IconShape(this.data, {this.strokeWidth = 1.5});

  final String data;
  final double strokeWidth;
}

const iconShapes = <IconId, IconShape>{
  IconId.play: IconShape('M8 5.5v13l10.5-6.5z'),
  IconId.pause: IconShape('M8.5 5.5v13M15.5 5.5v13'),
  IconId.prev: IconShape('M6.5 5.5v13M18 6l-9 6 9 6z'),
  IconId.next: IconShape('M17.5 5.5v13M6 6l9 6-9 6z'),
  IconId.shuffle: IconShape(
    'M3.5 7H7c4 0 5 10 9 10h4M3.5 17H7c1.6 0 2.7-1.6 3.7-3.4M13 9.7C14 8.3 15 7 16.5 7h3.5M17.5 4.5L20 7l-2.5 2.5M17.5 14.5L20 17l-2.5 2.5',
  ),
  IconId.repeat: IconShape(
    'M5 11V9.5A2.5 2.5 0 0 1 7.5 7H19M16.5 4.5L19 7l-2.5 2.5M19 13v1.5a2.5 2.5 0 0 1-2.5 2.5H5M7.5 14.5L5 17l2.5 2.5',
  ),
  IconId.heart: IconShape(
    'M12 19.5s-7-4.3-7-9.4A3.9 3.9 0 0 1 12 8a3.9 3.9 0 0 1 7 2.1c0 5.1-7 9.4-7 9.4z',
  ),
  IconId.queue: IconShape('M4 7h13M4 12h9M4 17h7M16 14v6l5-3z'),
  IconId.search: IconShape(
    'M17 11A6 6 0 1 1 5 11A6 6 0 1 1 17 11ZM20 20l-4.2-4.2',
  ),
  IconId.library: IconShape('M5 5v14M10 5v14M15 6.2l4.5 12.8'),
  IconId.download: IconShape('M12 4v11m0 0l-4-4m4 4l4-4M5 19.5h14'),
  IconId.more: IconShape('M5 12h.01M12 12h.01M19 12h.01', strokeWidth: 3),
  IconId.check: IconShape('M5 12.5l4.5 4.5L19 7.5'),
  IconId.close: IconShape('M6 6l12 12M18 6L6 18'),
  IconId.volume: IconShape(
    'M4 10v4h3.5L12 18V6L7.5 10zM15.5 9a4 4 0 0 1 0 6M18 6.5a8 8 0 0 1 0 11',
  ),
  IconId.down: IconShape('M6 9.5l6 6 6-6'),
  IconId.alert: IconShape('M12 9v4.5M12 17h.01M12 3.8l9 15.7H3z'),
  IconId.playing: IconShape('M7 19v-9M12 19V5M17 19v-6', strokeWidth: 2.2),
};

final _paths = <IconId, Path>{};

Path iconPath(IconId id) {
  return _paths.putIfAbsent(id, () => parseSvgPath(iconShapes[id]!.data));
}
