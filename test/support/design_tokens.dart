import 'dart:convert';
import 'dart:io';

const designTokensPath = '../altynemel-design/tokens.json';

bool get designTokensAvailable => File(designTokensPath).existsSync();

Map<String, dynamic> loadDesignTokens() {
  return jsonDecode(File(designTokensPath).readAsStringSync())
      as Map<String, dynamic>;
}

Map<String, String> colorTokens(Map<String, dynamic> tokens, String theme) {
  final list = (tokens['color'] as Map<String, dynamic>)['tokens'] as List;
  return {
    for (final item in list)
      (item as Map<String, dynamic>)['name'] as String:
          (item['value'] as Map<String, dynamic>)[theme] as String,
  };
}

Map<String, double> pixelTokens(Map<String, dynamic> tokens, String group) {
  final list = (tokens[group] as Map<String, dynamic>)['tokens'] as List;
  return {
    for (final item in list)
      (item as Map<String, dynamic>)['name'] as String: double.parse(
        (item['value'] as String).replaceAll('px', ''),
      ),
  };
}

Map<String, Map<String, dynamic>> typeTokens(Map<String, dynamic> tokens) {
  final groups = (tokens['type'] as Map<String, dynamic>)['groups'] as List;
  return {
    for (final group in groups)
      for (final style in (group as Map<String, dynamic>)['styles'] as List)
        (style as Map<String, dynamic>)['name'] as String: style,
  };
}
