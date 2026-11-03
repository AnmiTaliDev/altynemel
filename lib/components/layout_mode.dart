import 'package:flutter/widgets.dart';

import '../settings/app_settings_scope.dart';
import '../settings/catalog.dart';
import '../theme/spacing.dart';

const double phoneBelow = 600;

double phoneThreshold(BuildContext context) {
  final settings = AppSettingsScope.maybeOf(context);
  return (settings?.valueOf(phoneLayoutBelow) ?? phoneBelow).toDouble();
}

bool isPhoneWidth(BuildContext context, double width) =>
    width < phoneThreshold(context);

bool isPhone(BuildContext context) =>
    isPhoneWidth(context, MediaQuery.sizeOf(context).width);

double pageGutter(BuildContext context) {
  final phone = isPhone(context);
  final settings = AppSettingsScope.maybeOf(context);
  if (settings == null) return phone ? space4 : space6;
  return settings.valueOf(phone ? pageMarginPhone : pageMargin).toDouble();
}
