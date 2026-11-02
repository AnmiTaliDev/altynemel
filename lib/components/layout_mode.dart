import 'package:flutter/widgets.dart';

import '../theme/spacing.dart';

const double phoneBelow = 600;

bool isPhoneWidth(double windowWidth) => windowWidth < phoneBelow;

bool isPhone(BuildContext context) =>
    isPhoneWidth(MediaQuery.sizeOf(context).width);

double pageGutter(BuildContext context) => isPhone(context) ? space4 : space6;
