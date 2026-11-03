import 'setting_def.dart';

List<SettingDef<Object>> searchDefinitions(
  List<SettingDef<Object>> definitions,
  String query,
) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return definitions;
  return [
    for (final def in definitions)
      if (_matches(def, words)) def,
  ];
}

bool _matches(SettingDef<Object> def, List<String> words) {
  final haystack = '${def.label} ${def.hint} ${def.group.title} ${def.key}'
      .toLowerCase();
  return words.every(haystack.contains);
}

Map<SettingGroup, List<SettingDef<Object>>> groupDefinitions(
  List<SettingDef<Object>> definitions,
) {
  return {
    for (final group in SettingGroup.values)
      if (definitions.any((def) => def.group == group))
        group: [
          for (final def in definitions)
            if (def.group == group) def,
        ],
  };
}
