import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';
import 'search_field.dart';

enum SidebarDestination { nowPlaying, library, playlists, queue, settings }

class SidebarPlaylist {
  const SidebarPlaylist({required this.id, required this.name});

  final String id;
  final String name;
}

BoxDecoration _panelDecoration(BuildContext context) {
  final colors = AltynemelColors.of(context);
  final style = AltynemelStyle.of(context);
  if (style.material) {
    return BoxDecoration(color: style.scheme!.surfaceContainerLow);
  }
  return BoxDecoration(
    border: Border(
      right: BorderSide(color: colors.surfaceEdge, width: borderWidth),
    ),
  );
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
    this.dragArea,
    this.compact = false,
    this.onSearch,
  });

  final SidebarDestination? destination;
  final ValueChanged<SidebarDestination> onDestination;
  final List<SidebarPlaylist> playlists;
  final String? selectedPlaylistId;
  final ValueChanged<String> onPlaylist;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final Widget Function(Widget child)? dragArea;
  final bool compact;
  final VoidCallback? onSearch;

  Widget _wrapDrag(Widget child) => dragArea == null ? child : dragArea!(child);

  Widget _rail(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: Strings.mainNavigation,
      child: Container(
        decoration: _panelDecoration(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: space5),
          child: Column(
            children: [
              _wrapDrag(const SizedBox(height: 28, width: double.infinity)),
              const SizedBox(height: space5),
              _RailItem(
                icon: IconId.search,
                label: Strings.search,
                current: false,
                onPressed: onSearch,
              ),
              const SizedBox(height: space5),
              _RailItem(
                icon: IconId.playing,
                label: Strings.nowPlaying,
                current: destination == SidebarDestination.nowPlaying,
                onPressed: () => onDestination(SidebarDestination.nowPlaying),
              ),
              _RailItem(
                icon: IconId.library,
                label: Strings.library,
                current: destination == SidebarDestination.library,
                onPressed: () => onDestination(SidebarDestination.library),
              ),
              _RailItem(
                icon: IconId.queue,
                label: Strings.queue,
                current: destination == SidebarDestination.queue,
                onPressed: () => onDestination(SidebarDestination.queue),
              ),
              const SizedBox(height: space5),
              for (final playlist in playlists)
                _RailItem(
                  label: playlist.name,
                  current: playlist.id == selectedPlaylistId,
                  onPressed: () => onPlaylist(playlist.id),
                ),
              const SizedBox(height: space5),
              _RailItem(
                icon: IconId.settings,
                label: Strings.settings,
                current: destination == SidebarDestination.settings,
                onPressed: () => onDestination(SidebarDestination.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _rail(context);
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
        decoration: _panelDecoration(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: space5,
            horizontal: space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _wrapDrag(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: space3),
                  child: Semantics(
                    header: true,
                    child: Text(Strings.appName, style: brand),
                  ),
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
              const SizedBox(height: space5),
              _NavItem(
                label: Strings.settings,
                current: destination == SidebarDestination.settings,
                onPressed: () => onDestination(SidebarDestination.settings),
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

  Widget _materialItem(
    BuildContext context,
    ColorScheme scheme,
    AltynemelTextStyles text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Pressable(
        onPressed: onPressed,
        radius: 28,
        semanticLabel: label,
        selected: current,
        builder: (context, state) {
          final foreground = current
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant;
          final base = current ? scheme.secondaryContainer : Colors.transparent;
          final layer = state.pressed
              ? 0.12
              : (state.hovered || state.focused)
              ? 0.08
              : 0.0;
          return Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: space4),
            decoration: BoxDecoration(
              color: layer == 0
                  ? base
                  : Color.alphaBlend(foreground.withValues(alpha: layer), base),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  AltynemelIcon(icon!, size: 24, color: foreground),
                  const SizedBox(width: space3),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: text.bodyStrong.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    if (style.material) return _materialItem(context, style.scheme!, text);
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

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.label,
    required this.current,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final bool current;
  final VoidCallback? onPressed;
  final IconId? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    final scheme = style.scheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Pressable(
          onPressed: onPressed,
          radius: radiusControl,
          semanticLabel: label,
          selected: current,
          builder: (context, state) {
            if (style.material) {
              final foreground = current
                  ? scheme!.onSecondaryContainer
                  : scheme!.onSurfaceVariant;
              final base = current
                  ? scheme.secondaryContainer
                  : Colors.transparent;
              final layer = state.pressed
                  ? 0.12
                  : (state.hovered || state.focused)
                  ? 0.08
                  : 0.0;
              return SizedBox(
                width: 56,
                height: targetMin,
                child: Center(
                  child: Container(
                    width: 56,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: layer == 0
                          ? base
                          : Color.alphaBlend(
                              foreground.withValues(alpha: layer),
                              base,
                            ),
                      borderRadius: borderRadiusPill,
                    ),
                    child: icon != null
                        ? AltynemelIcon(icon!, size: 24, color: foreground)
                        : Text(
                            label.isEmpty
                                ? ''
                                : String.fromCharCode(
                                    label.runes.first,
                                  ).toUpperCase(),
                            style: text.bodyStrong.copyWith(color: foreground),
                          ),
                  ),
                ),
              );
            }
            final highlighted = current || state.hovered;
            final color = highlighted ? colors.ink : colors.inkMuted;
            return Container(
              width: targetMin,
              height: targetMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted ? colors.surfaceHigh : Colors.transparent,
                borderRadius: borderRadiusControl,
              ),
              child: icon != null
                  ? AltynemelIcon(icon!, size: 22, color: color)
                  : Text(
                      label.isEmpty
                          ? ''
                          : String.fromCharCode(
                              label.runes.first,
                            ).toUpperCase(),
                      style: text.bodyStrong.copyWith(color: color),
                    ),
            );
          },
        ),
      ),
    );
  }
}
