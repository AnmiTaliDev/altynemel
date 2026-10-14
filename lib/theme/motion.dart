import 'package:flutter/widgets.dart';

const Duration motionQuick = Duration(milliseconds: 160);
const Duration motionSheet = Duration(milliseconds: 280);
const Curve motionCurve = Cubic(0.2, 0, 0, 1);

Duration motionDuration(BuildContext context, Duration duration) {
  return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
