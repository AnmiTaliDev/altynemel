import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/button.dart';
import '../settings/app_settings.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'setup_progress.dart';
import 'setup_step.dart';
import 'steps/appearance_step.dart';
import 'steps/library_step.dart';
import 'steps/playback_step.dart';
import 'steps/welcome_step.dart';

const double setupWideFrom = 840;
const double setupContentWidth = 680;

String _title(SetupStep step) => switch (step) {
  SetupStep.welcome => Strings.setupWelcomeTitle,
  SetupStep.appearance => Strings.setupAppearanceTitle,
  SetupStep.library => Strings.setupLibraryTitle,
  SetupStep.playback => Strings.setupPlaybackTitle,
  SetupStep.finish => Strings.setupFinishTitle,
};

String _hint(SetupStep step) => switch (step) {
  SetupStep.welcome => Strings.setupWelcomeBody,
  SetupStep.appearance => Strings.setupAppearanceHint,
  SetupStep.library => Strings.setupLibraryHint,
  SetupStep.playback => Strings.setupPlaybackHint,
  SetupStep.finish => Strings.setupFinishHint,
};

class SetupWizard extends StatefulWidget {
  const SetupWizard({
    super.key,
    required this.settings,
    this.titleBar,
    this.initialStep = SetupStep.welcome,
    this.onChooseFolder,
    this.onRequestAccess,
  });

  final AppSettings settings;
  final Widget? titleBar;
  final Future<void> Function()? onChooseFolder;
  final Future<bool> Function()? onRequestAccess;
  final SetupStep initialStep;

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  late SetupStep _step = widget.initialStep;
  bool _forward = true;

  void _go(SetupStep? target, {required bool forward}) {
    if (target == null) return;
    setState(() {
      _forward = forward;
      _step = target;
    });
  }

  void _next() {
    if (_step.isLast) {
      widget.settings.setSetupCompleted(true);
    } else {
      _go(_step.next, forward: true);
    }
  }

  void _back() => _go(_step.previous, forward: false);

  void _skipAll() => widget.settings.setSetupCompleted(true);

  Widget _body(SetupStep step) => switch (step) {
    SetupStep.welcome => const WelcomeStep(),
    SetupStep.appearance => AppearanceStep(settings: widget.settings),
    SetupStep.playback => PlaybackStep(settings: widget.settings),
    SetupStep.library => LibraryStep(
      settings: widget.settings,
      onChooseFolder: widget.onChooseFolder,
      onRequestAccess: widget.onRequestAccess,
    ),
    _ => const SizedBox.shrink(),
  };

  Widget _sidePanel(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Container(
      width: 280,
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(space5, space6, space5, space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(Strings.appName, style: text.displayMd),
          ),
          const SizedBox(height: space6),
          SetupStepper(current: _step),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, SetupStep step) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(_title(step), style: text.displayLg),
        ),
        const SizedBox(height: space3),
        Text(_hint(step), style: text.bodyLg.copyWith(color: colors.inkMuted)),
      ],
    );
  }

  Widget _page(BuildContext context) {
    final step = _step;
    return SingleChildScrollView(
      key: ValueKey(step),
      padding: const EdgeInsets.symmetric(vertical: space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, step),
          const SizedBox(height: space5),
          _body(step),
        ],
      ),
    );
  }

  Widget _transition(BuildContext context) {
    final offset = _forward ? const Offset(0.04, 0) : const Offset(-0.04, 0);
    return AnimatedSwitcher(
      duration: motionDuration(context, motionSheet),
      switchInCurve: motionCurve,
      switchOutCurve: motionCurve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: offset,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: _page(context),
    );
  }

  Widget _navigation(BuildContext context) {
    final step = _step;
    final primary = AltynemelButton(
      label: step.isLast ? Strings.setupFinish : Strings.setupNext,
      kind: ButtonKind.primary,
      onPressed: _next,
    );
    final left = step.isFirst
        ? AltynemelButton(
            label: Strings.setupSkipAll,
            kind: ButtonKind.text,
            onPressed: _skipAll,
          )
        : AltynemelButton(
            label: Strings.setupBack,
            kind: ButtonKind.text,
            onPressed: _back,
          );
    final skip = step.canSkip
        ? AltynemelButton(
            label: Strings.setupSkip,
            kind: ButtonKind.text,
            onPressed: _next,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: space4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                primary,
                const SizedBox(height: space2),
                Row(children: [left, const Spacer(), ?skip]),
              ],
            );
          }
          return Row(
            children: [
              left,
              const Spacer(),
              if (skip != null) ...[skip, const SizedBox(width: space2)],
              primary,
            ],
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: setupContentWidth),
              child: _transition(context),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: setupContentWidth),
            child: _navigation(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _next,
        const SingleActivator(LogicalKeyboardKey.escape): _back,
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: colors.ground,
          child: Column(
            children: [
              ?widget.titleBar,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= setupWideFrom) {
                      return Row(
                        children: [
                          _sidePanel(context),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: space6,
                              ),
                              child: _content(context),
                            ),
                          ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: space4),
                      child: Column(
                        children: [
                          const SizedBox(height: space4),
                          SetupSegments(current: _step),
                          Expanded(child: _content(context)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
