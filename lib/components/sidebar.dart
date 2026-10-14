import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';
import 'search_field.dart';

enum SidebarDestination { nowPlaying, library, queue }

class SidebarPlaylist {
  const SidebarPlaylist({required this.id, required this.name});

  final String id;
  final String name;
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.destination,
    required this.onDestination,
    required this.playlists,
    required this.onPlaylist,
    this.selectedPlaylistId,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
  });

  final SidebarDestination? destination;
  final ValueChanged<SidebarDestination> onDestination;
  final List<SidebarPlaylist> playlists;
  final String? selectedPlaylistId;
  final ValueChanged<String> onPlaylist;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final brand = text.displayMd.copyWith(
      fontSize: 22,
      height: 28 / 22,
      letterSpacing: -0.03 * 22,
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.mainNavigation,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: colors.line, width: borderWidth),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: space5,
            horizontal: space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: space3),
                child: Semantics(
                  header: true,
                  child: Text(Strings.appName, style: brand),
                ),
              ),
              const SizedBox(height: space5),
              SearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: space5),
              _NavItem(
                icon: IconId.playing,
                label: Strings.nowPlaying,
                current: destination == SidebarDestination.nowPlaying,
                onPressed: () => onDestination(SidebarDestination.nowPlaying),
              ),
              _NavItem(
                icon: IconId.library,
                label: Strings.library,
                current: destination == SidebarDestination.library,
                onPressed: () => onDestination(SidebarDestination.library),
              ),
              _NavItem(
                icon: IconId.queue,
                label: Strings.queue,
                current: destination == SidebarDestination.queue,
                onPressed: () => onDestination(SidebarDestination.queue),
              ),
              const SizedBox(height: space5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: space3),
                child: Text(
                  Strings.playlists,
                  style: text.label.copyWith(color: colors.inkMuted),
                ),
              ),
              const SizedBox(height: space2),
              for (final playlist in playlists)
                _NavItem(
                  label: playlist.name,
                  current: playlist.id == selectedPlaylistId,
                  onPressed: () => onPlaylist(playlist.id),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.current,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final bool current;
  final VoidCallback onPressed;
  final IconId? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Pressable(
        onPressed: onPressed,
        radius: radiusControl,
        semanticLabel: label,
        selected: current,
        builder: (context, state) {
          final highlighted = current || state.hovered;
          return Container(
            constraints: const BoxConstraints(minHeight: targetPointer),
            padding: const EdgeInsets.symmetric(horizontal: space3),
            decoration: BoxDecoration(
              color: highlighted ? colors.surfaceHigh : Colors.transparent,
              borderRadius: borderRadiusControl,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  AltynemelIcon(
                    icon!,
                    size: 20,
                    color: highlighted ? colors.ink : colors.inkMuted,
                  ),
                  const SizedBox(width: space3),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: text.bodyStrong.copyWith(
                      color: highlighted ? colors.ink : colors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
