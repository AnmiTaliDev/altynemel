import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../components/window_bar.dart';
import '../integration/android_storage.dart';
import '../integration/window_service.dart';
import '../settings/app_settings.dart';
import 'setup_wizard.dart';

Future<void> chooseLibraryFolder(AppSettings settings) async {
  final path = await getDirectoryPath(initialDirectory: settings.libraryFolder);
  if (path != null) settings.setLibraryFolder(path);
}

Future<bool> requestAudioAccess(AppSettings settings) async {
  final granted = await requestAndroidAudioAccess();
  if (granted && settings.libraryFolder == null) {
    settings.setLibraryFolder(androidMusicFolder);
  }
  return granted;
}

class SetupHost extends StatelessWidget {
  const SetupHost({super.key, required this.settings, this.window});

  final AppSettings settings;
  final WindowService? window;

  @override
  Widget build(BuildContext context) {
    final service = window;
    final titleBar = service == null
        ? null
        : ValueListenableBuilder<bool>(
            valueListenable: service.maximized,
            builder: (context, maximized, _) => WindowBar(
              maximized: maximized,
              onMinimize: service.minimize,
              onToggleMaximize: service.toggleMaximize,
              onClose: service.close,
            ),
          );
    final wizard = SetupWizard(
      settings: settings,
      titleBar: titleBar,
      onChooseFolder: () => chooseLibraryFolder(settings),
      onRequestAccess: Platform.isAndroid
          ? () => requestAudioAccess(settings)
          : null,
    );
    if (service == null) return wizard;
    return DragToResizeArea(resizeEdgeSize: 6, child: wizard);
  }
}
