import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format/time_format.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'cover_art.dart';
import 'icon.dart';
import 'icon_button.dart';
import 'icon_data.dart';
import 'pressable.dart';
import 'time_label.dart';
import 'track_row.dart';

const double _numberColumn = 40;
const double _timeColumn = 72;

class TrackTableHeader extends StatelessWidget {
  const TrackTableHeader({super.key, required this.showAlbum});

  final bool showAlbum;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final style = AltynemelTextStyles.of(
      context,
    ).label.copyWith(color: colors.inkMuted);
    return Container(
      constraints: const BoxConstraints(minHeight: targetPointer),
      padding: const EdgeInsets.symmetric(horizontal: space3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.line, width: borderWidth),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _numberColumn,
            child: Text(
              Strings.columnNumber,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const SizedBox(width: space4),
          Expanded(flex: 4, child: Text(Strings.columnTitle, style: style)),
          if (showAlbum) ...[
            const SizedBox(width: space4),
            Expanded(flex: 3, child: Text(Strings.columnAlbum, style: style)),
          ],
          const SizedBox(width: space4),
          SizedBox(
            width: _timeColumn,
            child: Text(
              Strings.columnTime,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
          const SizedBox(width: space4 + targetPointer),
        ],
      ),
    );
  }
}

class TrackTableRow extends StatefulWidget {
  const TrackTableRow({
    super.key,
    required this.number,
    required this.title,
    required this.artist,
    required this.duration,
    required this.onSelect,
    required this.onPlay,
    required this.onMore,
    required this.showAlbum,
    this.album,
    this.image,
    this.isCurrent = false,
    this.isPlaying = false,
    this.isSelected = false,
    this.availability = TrackAvailability.available,
  });

  final int number;
  final String title;
  final String artist;
  final String? album;
  final Duration duration;
  final ImageProvider? image;
  final bool isCurrent;
  final bool isPlaying;
  final bool isSelected;
  final bool showAlbum;
  final TrackAvailability availability;
  final VoidCallback onSelect;
  final VoidCallback onPlay;
  final VoidCallback onMore;

  @override
  State<TrackTableRow> createState() => _TrackTableRowState();
}

class _TrackTableRowState extends State<TrackTableRow> {
  bool _hovered = false;
  bool _hasFocus = false;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final shiftMenu =
        event.logicalKey == LogicalKeyboardKey.f10 &&
        HardwareKeyboard.instance.isShiftPressed;
    if (event is KeyDownEvent &&
        (shiftMenu || event.logicalKey == LogicalKeyboardKey.contextMenu)) {
      widget.onMore();
      return KeyEventResult.handled;
    }
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => TraversalDirection.down,
      LogicalKeyboardKey.arrowUp => TraversalDirection.up,
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    FocusManager.instance.primaryFocus?.focusInDirection(direction);
    return KeyEventResult.handled;
  }

  String _spokenLabel() {
    final parts = [
      widget.title,
      widget.artist,
      ?widget.album,
      spokenDuration(widget.duration),
      if (widget.availability == TrackAvailability.unavailableOffline)
        Strings.unavailableOffline,
      if (widget.isCurrent && widget.isPlaying) Strings.playingNow,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final unavailable =
        widget.availability == TrackAvailability.unavailableOffline;
    final showMore = _hovered || _hasFocus || widget.isSelected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKeyEvent,
        onFocusChange: (value) => setState(() => _hasFocus = value),
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onSecondaryTap: widget.onMore,
              child: Pressable(
                onPressed: () {
                  widget.onSelect();
                  if (!unavailable) widget.onPlay();
                },
                radius: radiusControl,
                semanticLabel: _spokenLabel(),
                selected: widget.isSelected,
                builder: (context, state) {
                  final Color background;
                  if (widget.isCurrent) {
                    background = colors.surface;
                  } else if (widget.isSelected || state.hovered) {
                    background = colors.surfaceHigh;
                  } else {
                    background = Colors.transparent;
                  }
                  return Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.symmetric(horizontal: space3),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: borderRadiusControl,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        if (widget.isCurrent)
                          Positioned(
                            left: -space3,
                            top: space3,
                            bottom: space3,
                            width: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.accent,
                                borderRadius: borderRadiusPill,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            SizedBox(
                              width: _numberColumn,
                              child: Center(
                                child: widget.isCurrent && widget.isPlaying
                                    ? AltynemelIcon(
                                        IconId.playing,
                                        size: 20,
                                        color: colors.ink,
                                      )
                                    : Text(
                                        '${widget.number}',
                                        style: text.time.copyWith(
                                          color: widget.isCurrent
                                              ? colors.ink
                                              : colors.inkMuted,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: space4),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: space2,
                                ),
                                child: Row(
                                  children: [
                                    CoverArt(size: 40, image: widget.image),
                                    const SizedBox(width: space3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.title,
                                            style: text.bodyStrong.copyWith(
                                              color: unavailable
                                                  ? colors.inkDisabled
                                                  : colors.ink,
                                            ),
                                          ),
                                          Wrap(
                                            spacing: space2,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                widget.artist,
                                                style: text.caption.copyWith(
                                                  color: colors.inkMuted,
                                                ),
                                              ),
                                              AvailabilityFlag(
                                                widget.availability,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.showAlbum) ...[
                              const SizedBox(width: space4),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  widget.album ?? '',
                                  style: text.body.copyWith(
                                    color: colors.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: space4),
                            SizedBox(
                              width: _timeColumn,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TimeLabel(widget.duration),
                              ),
                            ),
                            const SizedBox(width: space4 + targetPointer),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: space3,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: showMore ? 1 : 0,
                  alwaysIncludeSemantics: true,
                  child: AltynemelIconButton(
                    icon: IconId.more,
                    label: Strings.moreAbout(widget.title),
                    compact: true,
                    onPressed: widget.onMore,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
