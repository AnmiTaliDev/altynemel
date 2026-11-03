const _groups = {
  'a': 'àáâãäåāăą',
  'c': 'çćč',
  'd': 'ďđ',
  'e': 'èéêëēėęě',
  'g': 'ğ',
  'i': 'ìíîïīı',
  'l': 'ł',
  'n': 'ñńň',
  'o': 'òóôõöøō',
  's': 'šśş',
  't': 'ť',
  'u': 'ùúûüūůű',
  'y': 'ýÿ',
  'z': 'žźż',
  'е': 'ё',
  'и': 'й',
};

final Map<int, String> _folded = {
  for (final entry in _groups.entries)
    for (final rune in entry.value.runes) rune: entry.key,
};

String foldAccents(String value) {
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    buffer.write(_folded[rune] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}
