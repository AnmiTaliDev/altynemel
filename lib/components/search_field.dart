import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
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
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return FocusRing(
      visible: _focused,
      radius: radiusPill,
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (value) => setState(() => _focused = value),
        child: Semantics(
          textField: true,
          label: Strings.search,
          excludeSemantics: false,
          child: Container(
            constraints: const BoxConstraints(minHeight: targetPointer),
            padding: const EdgeInsets.symmetric(horizontal: space3),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: borderRadiusPill,
              border: Border.all(color: colors.lineStrong, width: borderWidth),
            ),
            child: Row(
              children: [
                AltynemelIcon(IconId.search, size: 20, color: colors.inkMuted),
                const SizedBox(width: space2),
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
                      hintText: Strings.search,
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
