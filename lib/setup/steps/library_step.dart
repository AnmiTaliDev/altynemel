import 'package:flutter/material.dart';

import '../../components/button.dart';
import '../../components/icon.dart';
import '../../components/icon_data.dart';
import '../../settings/app_settings.dart';
import '../../strings.dart';
import '../../theme/colors.dart';
import '../../theme/radii.dart';
import '../../theme/spacing.dart';
import '../../theme/style.dart';
import '../../theme/text_styles.dart';

enum AccessState { unknown, granted, denied }

class LibraryStep extends StatefulWidget {
  const LibraryStep({
    super.key,
    required this.settings,
    this.onChooseFolder,
    this.onRequestAccess,
  });

  final AppSettings settings;
  final Future<void> Function()? onChooseFolder;
  final Future<bool> Function()? onRequestAccess;

  @override
  State<LibraryStep> createState() => _LibraryStepState();
}

class _LibraryStepState extends State<LibraryStep> {
  AccessState _access = AccessState.unknown;

  Future<void> _requestAccess() async {
    final granted = await widget.onRequestAccess!();
    if (!mounted) return;
    setState(
      () => _access = granted ? AccessState.granted : AccessState.denied,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final folder = widget.settings.libraryFolder;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.onRequestAccess != null) ...[
              _Panel(
                icon: IconId.volume,
                title: Strings.setupAccessAllow,
                detail: switch (_access) {
                  AccessState.unknown => null,
                  AccessState.granted => Strings.setupAccessGranted,
                  AccessState.denied => Strings.setupAccessDenied,
                },
                action: AltynemelButton(
                  label: Strings.setupAccessAllow,
                  kind: _access == AccessState.granted
                      ? ButtonKind.secondary
                      : ButtonKind.primary,
                  onPressed: _requestAccess,
                ),
              ),
              const SizedBox(height: space3),
            ],
            _Panel(
              icon: IconId.library,
              title: Strings.libraryFolder,
              detail: folder == null
                  ? Strings.setupLibraryNone
                  : Strings.setupLibraryChosen(folder),
              action: widget.onChooseFolder == null
                  ? Text(
                      Strings.unavailableInBuild,
                      style: text.caption.copyWith(color: colors.inkMuted),
                    )
                  : AltynemelButton(
                      label: folder == null
                          ? Strings.setupLibraryChoose
                          : Strings.setupLibraryChange,
                      kind: folder == null
                          ? ButtonKind.primary
                          : ButtonKind.secondary,
                      onPressed: widget.onChooseFolder,
                    ),
            ),
            const SizedBox(height: space4),
            Text(
              Strings.setupLibraryLater,
              style: text.caption.copyWith(color: colors.inkMuted),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.action,
    this.detail,
  });

  final IconId icon;
  final String title;
  final String? detail;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    final style = AltynemelStyle.of(context);
    final badge = style.material
        ? style.scheme!.primaryContainer
        : colors.surfaceHigh;
    final glyph = style.material
        ? style.scheme!.onPrimaryContainer
        : colors.ink;
    return Container(
      padding: const EdgeInsets.all(space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadiusCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badge,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AltynemelIcon(icon, size: 24, color: glyph),
              ),
              const SizedBox(width: space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.bodyStrong),
                    if (detail != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          detail!,
                          style: text.caption.copyWith(color: colors.inkMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: space4),
          Align(alignment: Alignment.centerLeft, child: action),
        ],
      ),
    );
  }
}
