import 'package:flutter/widgets.dart';

import '../format/time_format.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class TimeLabel extends StatelessWidget {
  const TimeLabel(this.duration, {super.key, this.textAlign});

  final Duration duration;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    return Text(
      formatTime(duration),
      textAlign: textAlign,
      style: AltynemelTextStyles.of(
        context,
      ).time.copyWith(color: colors.inkMuted),
    );
  }
}
