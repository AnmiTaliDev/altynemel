import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

List<int> _synchsafe(int value) => [
  (value >> 21) & 0x7F,
  (value >> 14) & 0x7F,
  (value >> 7) & 0x7F,
  value & 0x7F,
];

List<int> _textFrame(String id, String text) {
  final data = [3, ...utf8.encode(text)];
  return [...ascii.encode(id), ..._synchsafe(data.length), 0, 0, ...data];
}

List<int> _pictureFrame(List<int> image, String mime) {
  final data = [0, ...ascii.encode(mime), 0, 3, 0, ...image];
  return [...ascii.encode('APIC'), ..._synchsafe(data.length), 0, 0, ...data];
}

final pngBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
]);

Uint8List mp3Bytes({
  String? title,
  String? artist,
  String? album,
  String? trackNumber,
  String? albumArtist,
  List<int>? picture,
}) {
  final frames = [
    if (title != null) ..._textFrame('TIT2', title),
    if (artist != null) ..._textFrame('TPE1', artist),
    if (albumArtist != null) ..._textFrame('TPE2', albumArtist),
    if (album != null) ..._textFrame('TALB', album),
    if (trackNumber != null) ..._textFrame('TRCK', trackNumber),
    if (picture != null) ..._pictureFrame(picture, 'image/png'),
  ];
  final header = [
    ...ascii.encode('ID3'),
    4,
    0,
    0,
    ..._synchsafe(frames.length),
  ];
  final mpegFrame = [0xFF, 0xFB, 0x90, 0x00, ...List.filled(413, 0)];
  return Uint8List.fromList([
    ...header,
    ...frames,
    for (var i = 0; i < 8; i++) ...mpegFrame,
  ]);
}

File writeFile(Directory directory, String relativePath, List<int> bytes) {
  final file = File('${directory.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  return file;
}
