import 'dart:convert';

import 'app_settings.dart';
import 'setting_def.dart';

const int transferVersion = 1;

String exportSettings(
  AppSettings settings,
  List<SettingDef<Object>> definitions,
) {
  return const JsonEncoder.withIndent('  ').convert({
    'version': transferVersion,
    'values': {
      for (final def in definitions)
        if (settings.isModified(def))
          def.key: def.encode(settings.valueOf(def)),
    },
  });
}

int? importSettings(
  AppSettings settings,
  List<SettingDef<Object>> definitions,
  String raw,
) {
  final Object? json;
  try {
    json = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (json is! Map || json['version'] != transferVersion) return null;
  final values = json['values'];
  if (values is! Map) return null;
  var applied = 0;
  for (final def in definitions) {
    final value = values[def.key];
    if (value is! String) continue;
    final decoded = def.decode(value);
    if (decoded == null) continue;
    settings.setValue(def, decoded);
    applied++;
  }
  return applied;
}
