import 'package:flutter/widgets.dart';

import 'grouping.dart';

class ArtistLinkScope extends InheritedWidget {
  const ArtistLinkScope({
    super.key,
    required this.onOpen,
    required this.split,
    this.separators = defaultArtistSeparators,
    required super.child,
  });

  final ValueChanged<String> onOpen;
  final bool split;
  final String separators;

  static ArtistLinkScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArtistLinkScope>();

  @override
  bool updateShouldNotify(ArtistLinkScope oldWidget) =>
      split != oldWidget.split || separators != oldWidget.separators;
}
