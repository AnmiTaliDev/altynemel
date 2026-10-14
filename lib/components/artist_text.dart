import 'package:flutter/material.dart';

import '../library/artist_link_scope.dart';
import '../library/grouping.dart';
import '../theme/colors.dart';
import 'pressable.dart';

class ArtistText extends StatelessWidget {
  const ArtistText(this.artist, {super.key, required this.style});

  final String artist;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final scope = ArtistLinkScope.maybeOf(context);
    if (scope == null || artist.trim().isEmpty) {
      return Text(artist, style: style);
    }
    final colors = AltynemelColors.of(context);
    final names = splitArtists(artist, enabled: scope.split);
    final labels = names.length == 1 ? [artist] : names;
    return Wrap(
      children: [
        for (var i = 0; i < names.length; i++) ...[
          Pressable(
            onPressed: () => scope.onOpen(names[i]),
            radius: 4,
            semanticLabel: names[i],
            builder: (context, state) => Text(
              labels[i],
              style: style.copyWith(
                color: state.hovered ? colors.ink : style.color,
                decoration: state.hovered
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: colors.ink,
              ),
            ),
          ),
          if (i < names.length - 1) Text(', ', style: style),
        ],
      ],
    );
  }
}
