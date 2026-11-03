import 'package:flutter/widgets.dart';

import '../settings/app_settings_scope.dart';
import '../settings/catalog.dart';
import '../theme/spacing.dart';

const double phoneBelow = 600;

bool isPhoneWidth(double windowWidth) => windowWidth < phoneBelow;

bool isPhone(BuildContext context) =>
    isPhoneWidth(MediaQuery.sizeOf(context).width);

double pageGutter(BuildContext context) {
  if (isPhone(context)) return space4;
  final settings = AppSettingsScope.maybeOf(context);
  if (settings == null) return space6;
  return settings.valueOf(pageMargin).toDouble();
}
