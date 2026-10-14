import 'package:flutter/widgets.dart';

const double albumColumnHiddenBelow = 720;

bool showAlbumColumn(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= albumColumnHiddenBelow;
}
