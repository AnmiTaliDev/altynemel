import 'package:flutter/widgets.dart';

class AlbumLinkScope extends InheritedWidget {
  const AlbumLinkScope({super.key, required this.onOpen, required super.child});

  final ValueChanged<String> onOpen;

  static AlbumLinkScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AlbumLinkScope>();

  @override
  bool updateShouldNotify(AlbumLinkScope oldWidget) => false;
}
