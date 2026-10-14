import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:window_manager/window_manager.dart';

import '../strings.dart';

const Size defaultWindowSize = Size(1100, 700);
const Size minimumWindowSize = Size(640, 480);

class WindowService with WindowListener {
  WindowService({this.onClosing});

  final Future<void> Function()? onClosing;
  final ValueNotifier<bool> maximized = ValueNotifier(false);

  Future<void> init() async {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: defaultWindowSize,
      minimumSize: minimumWindowSize,
      center: true,
      title: Strings.appName,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  Future<void> minimize() => windowManager.minimize();

  Future<void> toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  Future<void> close() => windowManager.close();

  @override
  void onWindowMaximize() => maximized.value = true;

  @override
  void onWindowUnmaximize() => maximized.value = false;

  @override
  void onWindowClose() async {
    await onClosing?.call();
    await windowManager.destroy();
  }

  void dispose() {
    windowManager.removeListener(this);
    maximized.dispose();
  }
}
