import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/style.dart';
import '../theme/text_styles.dart';
import 'focus_ring.dart';
import 'icon.dart';
import 'icon_data.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.label = Strings.search,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String label;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    final scheme = style.scheme;
    final material = style.material;
    return FocusRing(
      visible: _focused && !material,
      radius: radiusPill,
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (value) => setState(() => _focused = value),
        child: Semantics(
          textField: true,
          label: widget.label,
          excludeSemantics: false,
          child: Container(
            constraints: BoxConstraints(
              minHeight: material ? 56 : targetPointer,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: material ? space4 : space3,
            ),
            decoration: BoxDecoration(
              color: material ? scheme!.surfaceContainerHigh : colors.surface,
              borderRadius: borderRadiusPill,
              border: material
                  ? (_focused
                        ? Border.all(color: scheme!.primary, width: 2)
                        : Border.all(color: Colors.transparent, width: 2))
                  : Border.all(color: colors.lineStrong, width: borderWidth),
            ),
            child: Row(
              children: [
                AltynemelIcon(
                  IconId.search,
                  size: material ? 24 : 20,
                  color: material ? scheme!.onSurface : colors.inkMuted,
                ),
                SizedBox(width: material ? space3 : space2),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    style: text.body,
                    cursorColor: colors.ink,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.label,
                      hintStyle: text.body.copyWith(color: colors.inkMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
