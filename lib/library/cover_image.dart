import 'dart:io';

import 'package:flutter/painting.dart';

ImageProvider? coverImage(String? path, {int width = 320}) {
  if (path == null) return null;
  return ResizeImage(FileImage(File(path)), width: width);
}
