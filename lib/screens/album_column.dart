import 'package:flutter/widgets.dart';

import '../components/app_shell.dart';

const double albumColumnMinContentWidth = 700;

bool showAlbumColumn(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width - sidebarSlotWidth(width) >= albumColumnMinContentWidth;
}
