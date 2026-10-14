import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'icon.dart';
import 'icon_data.dart';
import 'pressable.dart';

Rect anchorRect(BuildContext context) {
  final box = context.findRenderObject()! as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}

class MenuLayout extends SingleChildLayoutDelegate {
  const MenuLayout(this.anchor);

  final Rect anchor;

  static const double gap = space2;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(constraints.maxWidth - 2 * gap, constraints.maxHeight - 2 * gap),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = anchor.isEmpty ? anchor.left : anchor.right - childSize.width;
    final maxX = size.width - childSize.width - gap;
    final x = left.clamp(gap, maxX < gap ? gap : maxX).toDouble();
    final below = anchor.bottom + space1;
    final above = anchor.top - space1 - childSize.height;
    final double y;
    if (below + childSize.height <= size.height - gap) {
      y = below;
    } else if (above >= gap) {
      y = above;
    } else {
      final maxY = size.height - childSize.height - gap;
      y = maxY < gap ? gap : maxY;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(MenuLayout oldDelegate) => anchor != oldDelegate.anchor;
}

class MenuPanel extends StatelessWidget {
  const MenuPanel({
    super.key,
    required this.semanticLabel,
    required this.children,
    this.title,
  });

  final String semanticLabel;
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: semanticLabel,
      child: Container(
        width: 288,
        padding: const EdgeInsets.all(space3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: borderRadiusControl,
          border: Border.all(color: colors.lineStrong, width: borderWidth),
        ),
        child: FocusTraversalGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    space3,
                    space1,
                    space3,
                    space3,
                  ),
                  child: Text(
                    title!,
                    style: text.caption.copyWith(color: colors.inkMuted),
                  ),
                ),
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: space2),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.autofocus = false,
    this.toggled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconId? icon;
  final bool autofocus;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Pressable(
      onPressed: onPressed,
      autofocus: autofocus,
      radius: radiusControl,
      semanticLabel: label,
      toggled: toggled,
      builder: (context, state) {
        final foreground = state.enabled ? colors.ink : colors.inkDisabled;
        return Container(
          constraints: const BoxConstraints(minHeight: targetPointer),
          padding: const EdgeInsets.symmetric(
            horizontal: space3,
            vertical: space2,
          ),
          decoration: BoxDecoration(
            color: state.hovered && state.enabled
                ? colors.surfaceHigh
                : Colors.transparent,
            borderRadius: borderRadiusControl,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: icon == null
                    ? null
                    : AltynemelIcon(icon!, size: 20, color: foreground),
              ),
              const SizedBox(width: space3),
              Expanded(
                child: Text(
                  label,
                  style: text.body.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MenuTextField extends StatelessWidget {
  const MenuTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Semantics(
      textField: true,
      label: hint,
      child: Container(
        constraints: const BoxConstraints(minHeight: targetPointer),
        margin: const EdgeInsets.symmetric(horizontal: space1),
        padding: const EdgeInsets.symmetric(horizontal: space3),
        decoration: BoxDecoration(
          borderRadius: borderRadiusControl,
          border: Border.all(color: colors.lineStrong, width: borderWidth),
        ),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          onSubmitted: onSubmitted,
          style: text.body,
          cursorColor: colors.ink,
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: text.body.copyWith(color: colors.inkMuted),
          ),
        ),
      ),
    );
  }
}
