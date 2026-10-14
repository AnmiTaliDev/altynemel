import 'package:flutter/widgets.dart';

import '../theme/radii.dart';
import 'focus_ring.dart';

class PressState {
  const PressState({
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.enabled,
  });

  final bool hovered;
  final bool focused;
  final bool pressed;
  final bool enabled;
}

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onPressed,
    required this.builder,
    this.onDoubleTap,
    this.radius = radiusControl,
    this.semanticLabel,
    this.toggled,
    this.selected,
    this.drawFocusRing = true,
    this.focusNode,
    this.autofocus = false,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onDoubleTap;
  final Widget Function(BuildContext context, PressState state) builder;
  final double radius;
  final String? semanticLabel;
  final bool? toggled;
  final bool? selected;
  final bool drawFocusRing;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _activate() {
    if (widget.onDoubleTap != null) {
      widget.onDoubleTap!();
    } else {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PressState(
      hovered: _hovered,
      focused: _focused,
      pressed: _pressed,
      enabled: _enabled,
    );
    Widget child = FocusableActionDetector(
      enabled: _enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: _enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onDoubleTap: _enabled ? widget.onDoubleTap : null,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: widget.builder(context, state),
      ),
    );
    if (widget.drawFocusRing) {
      child = FocusRing(visible: _focused, radius: widget.radius, child: child);
    }
    return Semantics(
      container: true,
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      toggled: widget.toggled,
      selected: widget.selected,
      onTap: widget.onPressed,
      excludeSemantics: widget.semanticLabel != null,
      child: child,
    );
  }
}
