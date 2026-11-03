enum SettingGroup {
  playback('Playback'),
  sound('Sound'),
  appearance('Appearance'),
  layout('Layout'),
  library('Library'),
  search('Search');

  const SettingGroup(this.title);

  final String title;
}

abstract class SettingDef<T extends Object> {
  const SettingDef({
    required this.key,
    required this.group,
    required this.label,
    required this.hint,
    required this.defaultValue,
  });

  final String key;
  final SettingGroup group;
  final String label;
  final String hint;
  final T defaultValue;

  String encode(T value);

  T? decode(String raw);

  T normalize(T value) => value;

  String describe(T value) => encode(value);
}

class IntSetting extends SettingDef<int> {
  const IntSetting({
    required super.key,
    required super.group,
    required super.label,
    required super.hint,
    required super.defaultValue,
    required this.min,
    required this.max,
    this.step = 1,
    this.unit = '',
  });

  final int min;
  final int max;
  final int step;
  final String unit;

  @override
  String encode(int value) => '$value';

  @override
  int? decode(String raw) => int.tryParse(raw);

  @override
  int normalize(int value) => value.clamp(min, max);

  @override
  String describe(int value) => unit.isEmpty ? '$value' : '$value $unit';
}

class DoubleSetting extends SettingDef<double> {
  const DoubleSetting({
    required super.key,
    required super.group,
    required super.label,
    required super.hint,
    required super.defaultValue,
    required this.min,
    required this.max,
    this.step = 0.1,
    this.decimals = 1,
    this.unit = '',
  });

  final double min;
  final double max;
  final double step;
  final int decimals;
  final String unit;

  @override
  String encode(double value) => value.toStringAsFixed(decimals);

  @override
  double? decode(String raw) => double.tryParse(raw);

  @override
  double normalize(double value) {
    final snapped = double.parse(value.toStringAsFixed(decimals));
    return snapped.clamp(min, max).toDouble();
  }

  @override
  String describe(double value) {
    final text = encode(value);
    return unit.isEmpty ? text : '$text $unit';
  }
}

class BoolSetting extends SettingDef<bool> {
  const BoolSetting({
    required super.key,
    required super.group,
    required super.label,
    required super.hint,
    required super.defaultValue,
  });

  @override
  String encode(bool value) => '$value';

  @override
  bool? decode(String raw) {
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    return null;
  }

  @override
  String describe(bool value) => value ? 'On' : 'Off';
}

class EnumSetting<E extends Enum> extends SettingDef<E> {
  const EnumSetting({
    required super.key,
    required super.group,
    required super.label,
    required super.hint,
    required super.defaultValue,
    required this.values,
    required this.labels,
  });

  final List<E> values;
  final Map<E, String> labels;

  @override
  String encode(E value) => value.name;

  @override
  E? decode(String raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }

  @override
  String describe(E value) => labels[value] ?? value.name;
}

class TextSetting extends SettingDef<String> {
  const TextSetting({
    required super.key,
    required super.group,
    required super.label,
    required super.hint,
    required super.defaultValue,
  });

  @override
  String encode(String value) => value;

  @override
  String? decode(String raw) => raw;

  @override
  String normalize(String value) => value.trim();
}
