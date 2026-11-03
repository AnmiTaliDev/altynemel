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
