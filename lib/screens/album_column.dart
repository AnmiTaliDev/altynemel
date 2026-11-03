import 'package:flutter/widgets.dart';

import '../components/app_shell.dart';
import '../settings/app_settings_scope.dart';
import '../settings/catalog.dart';

const double albumColumnMinContentWidth = 700;

bool showAlbumColumn(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final minimum =
      AppSettingsScope.maybeOf(context)?.valueOf(albumColumnMinWidth) ??
      albumColumnMinContentWidth.toInt();
  return width - sidebarSlotWidth(context) >= minimum;
}
