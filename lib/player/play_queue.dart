import 'dart:math';

import '../library/track.dart';
import 'repeat_setting.dart';

class PlayQueue {
  PlayQueue({Random? random}) : _random = random ?? Random();

  final Random _random;
  List<Track> _items = [];
  List<int> _order = [];
  List<int>? _pendingOrder;
  int _position = -1;
  bool _shuffle = false;
  RepeatSetting _repeat = RepeatSetting.off;

  List<Track> get items => List.unmodifiable(_items);
  List<Track> get ordered => [for (final i in _order) _items[i]];
  int get position => _position;
  bool get shuffle => _shuffle;
  RepeatSetting get repeat => _repeat;
  bool get isEmpty => _items.isEmpty;
  Track? get current => _position < 0 ? null : _items[_order[_position]];

  List<int> _naturalOrder() => List.generate(_items.length, (i) => i);

  List<int> _shuffled(List<int> indexes) {
    final copy = [...indexes];
    for (var i = copy.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  void load(List<Track> tracks, {int start = 0}) {
    _items = [...tracks];
    _pendingOrder = null;
    if (_items.isEmpty) {
      _order = [];
      _position = -1;
      return;
    }
    final first = start.clamp(0, _items.length - 1);
    if (_shuffle) {
      final rest = _naturalOrder()..remove(first);
      _order = [first, ..._shuffled(rest)];
      _position = 0;
    } else {
      _order = _naturalOrder();
      _position = first;
    }
  }

  void clear() => load(const []);

  void setShuffle(bool value) {
    if (_shuffle == value) return;
    _shuffle = value;
    _pendingOrder = null;
    if (_items.isEmpty) return;
    final currentIndex = _order[_position];
    if (value) {
      final rest = _naturalOrder()..remove(currentIndex);
      _order = [currentIndex, ..._shuffled(rest)];
      _position = 0;
    } else {
      _order = _naturalOrder();
      _position = currentIndex;
    }
  }

  void setRepeat(RepeatSetting value) {
    _repeat = value;
  }

  List<int> _cycleOrder() {
    return _pendingOrder ??= _buildNextCycle();
  }

  List<int> _buildNextCycle() {
    if (!_shuffle) return _naturalOrder();
    var next = _shuffled(_naturalOrder());
    if (next.length > 1 && next.first == _order.last) {
      final swap = 1 + _random.nextInt(next.length - 1);
      final tmp = next[0];
      next[0] = next[swap];
      next[swap] = tmp;
    }
    return next;
  }

  bool get _atEnd => _position + 1 >= _order.length;

  Track? peekNext({required bool auto}) {
    if (_items.isEmpty) return null;
    if (auto && _repeat == RepeatSetting.one) return current;
    if (!_atEnd) return _items[_order[_position + 1]];
    if (_repeat == RepeatSetting.all) return _items[_cycleOrder().first];
    return null;
  }

  Track? advance({required bool auto}) {
    if (_items.isEmpty) return null;
    if (auto && _repeat == RepeatSetting.one) return current;
    if (!_atEnd) {
      _position++;
      return current;
    }
    if (_repeat == RepeatSetting.all) {
      _order = _cycleOrder();
      _pendingOrder = null;
      _position = 0;
      return current;
    }
    return null;
  }

  Track? back() {
    if (_items.isEmpty) return null;
    if (_position > 0) {
      _position--;
      return current;
    }
    if (_repeat == RepeatSetting.all) {
      _position = _order.length - 1;
      return current;
    }
    return null;
  }

  bool jumpTo(int position) {
    if (position < 0 || position >= _order.length) return false;
    _position = position;
    return true;
  }

  void playNext(Track track) {
    _pendingOrder = null;
    _items.add(track);
    final index = _items.length - 1;
    if (_position < 0) {
      _order = [index];
      _position = 0;
    } else {
      _order.insert(_position + 1, index);
    }
  }

  void enqueue(Track track) {
    _pendingOrder = null;
    _items.add(track);
    final index = _items.length - 1;
    _order.add(index);
    if (_position < 0) _position = 0;
  }

  bool removeAt(int position) {
    if (position < 0 || position >= _order.length) return false;
    if (position == _position) return false;
    _pendingOrder = null;
    final index = _order.removeAt(position);
    _items.removeAt(index);
    for (var i = 0; i < _order.length; i++) {
      if (_order[i] > index) _order[i]--;
    }
    if (position < _position) _position--;
    return true;
  }

  Map<String, Object?> toJson() {
    return {
      'ids': [for (final t in _items) t.id],
      'order': _order,
      'position': _position,
      'shuffle': _shuffle,
      'repeat': _repeat.name,
    };
  }

  void restore(Map<String, Object?> json, Track? Function(String id) resolve) {
    final ids = (json['ids'] as List?)?.cast<String>() ?? const [];
    final order = (json['order'] as List?)?.cast<int>() ?? const [];
    final position = json['position'] as int? ?? -1;
    _shuffle = json['shuffle'] as bool? ?? false;
    _repeat = RepeatSetting.values.firstWhere(
      (r) => r.name == json['repeat'],
      orElse: () => RepeatSetting.off,
    );
    _pendingOrder = null;
    final remap = <int, int>{};
    final items = <Track>[];
    for (var i = 0; i < ids.length; i++) {
      final track = resolve(ids[i]);
      if (track != null) {
        remap[i] = items.length;
        items.add(track);
      }
    }
    _items = items;
    final newOrder = <int>[];
    var newPosition = -1;
    for (var p = 0; p < order.length; p++) {
      final mapped = remap[order[p]];
      if (mapped == null) continue;
      if (p == position) newPosition = newOrder.length;
      newOrder.add(mapped);
    }
    if (newOrder.length != items.length) {
      _order = _naturalOrder();
      _position = items.isEmpty ? -1 : 0;
      return;
    }
    _order = newOrder;
    if (items.isEmpty) {
      _position = -1;
    } else if (newPosition >= 0) {
      _position = newPosition;
    } else {
      _position = position.clamp(0, items.length - 1);
    }
  }
}
