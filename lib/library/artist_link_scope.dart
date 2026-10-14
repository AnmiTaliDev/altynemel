import 'package:flutter/widgets.dart';

class ArtistLinkScope extends InheritedWidget {
  const ArtistLinkScope({
    super.key,
    required this.onOpen,
    required this.split,
    required super.child,
  });

  final ValueChanged<String> onOpen;
  final bool split;

  static ArtistLinkScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArtistLinkScope>();

  @override
  bool updateShouldNotify(ArtistLinkScope oldWidget) =>
      split != oldWidget.split;
}
