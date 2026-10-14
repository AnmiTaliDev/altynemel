import 'package:flutter/material.dart';

import '../library/album_link_scope.dart';
import '../theme/colors.dart';
import 'pressable.dart';

class AlbumText extends StatelessWidget {
  const AlbumText(
    this.album, {
    super.key,
    required this.albumId,
    required this.style,
  });

  final String album;
  final String? albumId;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final scope = AlbumLinkScope.maybeOf(context);
    final id = albumId;
    if (scope == null || id == null || album.trim().isEmpty) {
      return Text(album, style: style);
    }
    final colors = AltynemelColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Pressable(
        onPressed: () => scope.onOpen(id),
        radius: 4,
        semanticLabel: album,
        builder: (context, state) => Text(
          album,
          style: style.copyWith(
            color: state.hovered ? colors.ink : style.color,
            decoration: state.hovered
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: colors.ink,
          ),
        ),
      ),
    );
  }
}
