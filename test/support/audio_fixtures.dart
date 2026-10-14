import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

Uint8List wavBytes({
  double seconds = 1,
  int sampleRate = 8000,
  double frequency = 440,
}) {
  final samples = (seconds * sampleRate).round();
  final data = ByteData(44 + samples * 2);
  void ascii4(int offset, String text) {
    for (var i = 0; i < 4; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  ascii4(0, 'RIFF');
  data.setUint32(4, 36 + samples * 2, Endian.little);
  ascii4(8, 'WAVE');
  ascii4(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii4(36, 'data');
  data.setUint32(40, samples * 2, Endian.little);
  for (var i = 0; i < samples; i++) {
    final value = (sin(2 * pi * frequency * i / sampleRate) * 8000).round();
    data.setInt16(44 + i * 2, value, Endian.little);
  }
  return data.buffer.asUint8List();
}
