import 'package:flutter/material.dart';

import '../settings/app_settings_scope.dart';
import '../settings/catalog.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'cover_art.dart';
import 'layout_mode.dart';
import 'pressable.dart';

double mediaTileCoverOf(BuildContext context) {
  final def = isPhone(context) ? tileCoverSizePhone : tileCoverSize;
  final settings = AppSettingsScope.maybeOf(context);
  return (settings?.valueOf(def) ?? def.defaultValue).toDouble();
}

double mediaTileWidthOf(BuildContext context) =>
    mediaTileCoverOf(context) + 2 * space2;

class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.title,
    required this.semanticLabel,
    required this.onPressed,
    this.subtitle,
    this.image,
  });

  final String title;
  final String? subtitle;
  final String semanticLabel;
  final ImageProvider? image;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return SizedBox(
      width: mediaTileWidthOf(context),
      child: Pressable(
        onPressed: onPressed,
        radius: radiusControl,
        semanticLabel: semanticLabel,
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(space2),
            decoration: BoxDecoration(
              color: state.hovered ? colors.surfaceHigh : Colors.transparent,
              borderRadius: borderRadiusControl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoverArt(
                  size: mediaTileCoverOf(context),
                  image: image,
                  albumName: title,
                ),
                const SizedBox(height: space2),
                Text(title, style: text.bodyStrong),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: text.caption.copyWith(color: colors.inkMuted),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
