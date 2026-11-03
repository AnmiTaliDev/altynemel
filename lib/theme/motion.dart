import 'package:flutter/widgets.dart';

import '../settings/app_settings_scope.dart';
import '../settings/catalog.dart';

const Duration motionQuick = Duration(milliseconds: 160);
const Duration motionSheet = Duration(milliseconds: 280);
const Curve motionCurve = Cubic(0.2, 0, 0, 1);

Duration motionDuration(BuildContext context, Duration duration) {
  if (MediaQuery.disableAnimationsOf(context)) return Duration.zero;
  final settings = AppSettingsScope.maybeOf(context);
  if (settings == null) return duration;
  final speed = settings.valueOf(animationSpeedPercent);
  return Duration(
    microseconds: (duration.inMicroseconds * 100 / speed).round(),
  );
}
