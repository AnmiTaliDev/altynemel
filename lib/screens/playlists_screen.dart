import 'package:flutter/material.dart';

import '../components/icon.dart';
import '../components/icon_data.dart';
import '../components/layout_mode.dart';
import '../components/pressable.dart';
import '../components/screen_header.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class PlaylistSummary {
  const PlaylistSummary({
    required this.id,
    required this.name,
    required this.trackCount,
  });

  final String id;
  final String name;
  final int trackCount;
}

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({
    super.key,
    required this.playlists,
    required this.onOpen,
  });

  final List<PlaylistSummary> playlists;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final gutter = pageGutter(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, space5, gutter, space4),
          sliver: const SliverToBoxAdapter(
            child: ScreenHeader(title: Strings.playlists),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, space5),
          sliver: SliverList.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Pressable(
                  onPressed: () => onOpen(playlist.id),
                  radius: radiusControl,
                  semanticLabel: playlist.name,
                  builder: (context, state) {
                    return Container(
                      constraints: const BoxConstraints(minHeight: targetMin),
                      padding: const EdgeInsets.symmetric(
                        horizontal: space3,
                        vertical: space2,
                      ),
                      decoration: BoxDecoration(
                        color: state.hovered
                            ? colors.surfaceHigh
                            : Colors.transparent,
                        borderRadius: borderRadiusControl,
                      ),
                      child: Row(
                        children: [
                          AltynemelIcon(
                            IconId.playlists,
                            size: 22,
                            color: colors.inkMuted,
                          ),
                          const SizedBox(width: space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.name,
                                  style: text.bodyStrong,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  Strings.songCount(playlist.trackCount),
                                  style: text.caption.copyWith(
                                    color: colors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
