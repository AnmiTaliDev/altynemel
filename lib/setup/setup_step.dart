import '../strings.dart';

enum SetupStep {
  welcome(Strings.setupStepWelcome),
  appearance(Strings.setupStepAppearance),
  library(Strings.setupStepLibrary),
  playback(Strings.setupStepPlayback),
  finish(Strings.setupStepFinish);

  const SetupStep(this.label);

  final String label;

  bool get isFirst => index == 0;

  bool get isLast => index == SetupStep.values.length - 1;

  SetupStep? get next => isLast ? null : SetupStep.values[index + 1];

  SetupStep? get previous => isFirst ? null : SetupStep.values[index - 1];

  bool get canSkip => this == library || this == playback;
}
