import 'choices.dart';
import 'setting_def.dart';

const crossfadeSeconds = IntSetting(
  key: 'crossfadeSeconds',
  group: SettingGroup.playback,
  label: 'Crossfade length',
  hint: 'Seconds during which two tracks overlap when crossfade is on.',
  defaultValue: 4,
  min: 1,
  max: 12,
  unit: 's',
);

const previousRestartSeconds = IntSetting(
  key: 'previousRestartSeconds',
  group: SettingGroup.playback,
  label: 'Previous button restart point',
  hint:
      'Past this many seconds the previous button restarts the track instead of going back. Zero always goes back.',
  defaultValue: 3,
  min: 0,
  max: 10,
  unit: 's',
);

const positionSaveSeconds = IntSetting(
  key: 'positionSaveSeconds',
  group: SettingGroup.playback,
  label: 'Position save interval',
  hint: 'How often the playback position is written while playing.',
  defaultValue: 5,
  min: 1,
  max: 60,
  unit: 's',
);

const crossfadeCurve = EnumSetting<CrossfadeCurve>(
  key: 'crossfadeCurve',
  group: SettingGroup.playback,
  label: 'Crossfade curve',
  hint: 'Equal power keeps the loudness steady, linear is a straight ramp.',
  defaultValue: CrossfadeCurve.equalPower,
  values: CrossfadeCurve.values,
  labels: crossfadeCurveLabels,
);

const crossfadeStepMs = IntSetting(
  key: 'crossfadeStepMs',
  group: SettingGroup.playback,
  label: 'Crossfade update step',
  hint: 'Time between volume updates during a crossfade. Smaller is smoother.',
  defaultValue: 50,
  min: 10,
  max: 200,
  step: 10,
  unit: 'ms',
);

const skipUnavailableTracks = BoolSetting(
  key: 'skipUnavailableTracks',
  group: SettingGroup.playback,
  label: 'Skip missing files',
  hint: 'Move on to the next track when a file is gone. Off stops playback.',
  defaultValue: true,
);

const defaultVolume = IntSetting(
  key: 'defaultVolume',
  group: SettingGroup.sound,
  label: 'Starting volume',
  hint: 'Volume used when there is no saved playback state.',
  defaultValue: 70,
  min: 0,
  max: 100,
  step: 5,
  unit: '%',
);

const maximumVolume = IntSetting(
  key: 'maximumVolume',
  group: SettingGroup.sound,
  label: 'Maximum volume',
  hint: 'Upper limit for the volume controls, to protect your ears.',
  defaultValue: 100,
  min: 10,
  max: 100,
  step: 5,
  unit: '%',
);

const resumeOnLaunch = BoolSetting(
  key: 'resumeOnLaunch',
  group: SettingGroup.playback,
  label: 'Resume playback on launch',
  hint: 'Start playing the restored track right after the app opens.',
  defaultValue: false,
);

const playbackSpeed = DoubleSetting(
  key: 'playbackSpeed',
  group: SettingGroup.sound,
  label: 'Playback speed',
  hint: 'Speed of every track. One is the original speed.',
  defaultValue: 1,
  min: 0.5,
  max: 2,
  step: 0.05,
  decimals: 2,
  unit: 'x',
);

const pitchCorrection = BoolSetting(
  key: 'pitchCorrection',
  group: SettingGroup.sound,
  label: 'Keep pitch at other speeds',
  hint: 'Correct the pitch when the playback speed is not one.',
  defaultValue: true,
);

const replayGain = EnumSetting<ReplayGainMode>(
  key: 'replayGain',
  group: SettingGroup.sound,
  label: 'Volume normalization',
  hint: 'Use ReplayGain tags to even out the loudness of tracks or albums.',
  defaultValue: ReplayGainMode.off,
  values: ReplayGainMode.values,
  labels: replayGainLabels,
);

const audioBufferSeconds = DoubleSetting(
  key: 'audioBufferSeconds',
  group: SettingGroup.sound,
  label: 'Audio buffer',
  hint: 'Length of the output buffer. Raise it if the sound crackles.',
  defaultValue: 0.2,
  min: 0.05,
  max: 2,
  step: 0.05,
  decimals: 2,
  unit: 's',
);

const seekStepSeconds = IntSetting(
  key: 'seekStepSeconds',
  group: SettingGroup.playback,
  label: 'Seek step',
  hint: 'Jump made by the left and right arrow keys.',
  defaultValue: 5,
  min: 1,
  max: 60,
  unit: 's',
);

const seekStepLongSeconds = IntSetting(
  key: 'seekStepLongSeconds',
  group: SettingGroup.playback,
  label: 'Long seek step',
  hint: 'Jump made by Shift with the left and right arrow keys.',
  defaultValue: 30,
  min: 5,
  max: 600,
  step: 5,
  unit: 's',
);

const textScalePercent = IntSetting(
  key: 'textScalePercent',
  group: SettingGroup.appearance,
  label: 'Text size',
  hint: 'Scales all text on top of the system text size.',
  defaultValue: 100,
  min: 70,
  max: 200,
  step: 5,
  unit: '%',
);

const animationSpeedPercent = IntSetting(
  key: 'animationSpeedPercent',
  group: SettingGroup.appearance,
  label: 'Animation speed',
  hint: 'Higher is faster. Has no effect when reduce motion is on.',
  defaultValue: 100,
  min: 25,
  max: 400,
  step: 25,
  unit: '%',
);

const accentColor = EnumSetting<AccentChoice>(
  key: 'accentColor',
  group: SettingGroup.appearance,
  label: 'Accent color',
  hint: 'Color of the current track marker, focus ring and primary buttons.',
  defaultValue: AccentChoice.theme,
  values: AccentChoice.values,
  labels: accentLabels,
);

const rowDensity = EnumSetting<RowDensity>(
  key: 'rowDensity',
  group: SettingGroup.layout,
  label: 'Track row height',
  hint: 'How much room each row in track lists takes.',
  defaultValue: RowDensity.comfortable,
  values: RowDensity.values,
  labels: rowDensityLabels,
);

const rowCoverSize = IntSetting(
  key: 'rowCoverSize',
  group: SettingGroup.layout,
  label: 'Track row cover size',
  hint: 'Size of the cover thumbnail in track lists.',
  defaultValue: 40,
  min: 24,
  max: 72,
  step: 4,
  unit: 'px',
);

const pageMargin = IntSetting(
  key: 'pageMargin',
  group: SettingGroup.layout,
  label: 'Page margin',
  hint: 'Space on the left and right of every screen on a desktop layout.',
  defaultValue: 32,
  min: 8,
  max: 96,
  step: 4,
  unit: 'px',
);

const pageMarginPhone = IntSetting(
  key: 'pageMarginPhone',
  group: SettingGroup.layout,
  label: 'Page margin on a phone',
  hint: 'Space on the left and right of every screen on a phone layout.',
  defaultValue: 16,
  min: 4,
  max: 32,
  step: 2,
  unit: 'px',
);

const tileCoverSize = IntSetting(
  key: 'tileCoverSize',
  group: SettingGroup.layout,
  label: 'Album tile size',
  hint: 'Cover size of the tiles in the album and artist grids.',
  defaultValue: 160,
  min: 100,
  max: 300,
  step: 10,
  unit: 'px',
);

const tileCoverSizePhone = IntSetting(
  key: 'tileCoverSizePhone',
  group: SettingGroup.layout,
  label: 'Album tile size on a phone',
  hint: 'Cover size of the tiles in the album and artist grids on a phone.',
  defaultValue: 140,
  min: 80,
  max: 200,
  step: 10,
  unit: 'px',
);

const sidebarExpandedWidth = IntSetting(
  key: 'sidebarExpandedWidth',
  group: SettingGroup.layout,
  label: 'Sidebar width',
  hint: 'Width of the full sidebar on wide windows.',
  defaultValue: 232,
  min: 160,
  max: 360,
  step: 4,
  unit: 'px',
);

const playerBarMinHeight = IntSetting(
  key: 'playerBarMinHeight',
  group: SettingGroup.layout,
  label: 'Player bar height',
  hint: 'Minimum height of the bar at the bottom of the window.',
  defaultValue: 88,
  min: 64,
  max: 160,
  step: 4,
  unit: 'px',
);

const phoneLayoutBelow = IntSetting(
  key: 'phoneLayoutBelow',
  group: SettingGroup.layout,
  label: 'Phone layout below',
  hint: 'Windows narrower than this switch to the layout with bottom tabs.',
  defaultValue: 600,
  min: 300,
  max: 900,
  step: 10,
  unit: 'px',
);

const compactSidebarBelow = IntSetting(
  key: 'compactSidebarBelow',
  group: SettingGroup.layout,
  label: 'Icon rail below',
  hint: 'Windows narrower than this shrink the sidebar to an icon rail.',
  defaultValue: 800,
  min: 400,
  max: 1400,
  step: 10,
  unit: 'px',
);

const compactPlayerBarBelow = IntSetting(
  key: 'compactPlayerBarBelow',
  group: SettingGroup.layout,
  label: 'Compact player bar below',
  hint: 'Windows narrower than this use the one row player bar.',
  defaultValue: 900,
  min: 500,
  max: 1400,
  step: 10,
  unit: 'px',
);

const albumColumnMinWidth = IntSetting(
  key: 'albumColumnMinWidth',
  group: SettingGroup.layout,
  label: 'Album column needs',
  hint:
      'Width of free space the track lists need before they show an album column.',
  defaultValue: 700,
  min: 300,
  max: 1400,
  step: 10,
  unit: 'px',
);

const nowPlayingWideFrom = IntSetting(
  key: 'nowPlayingWideFrom',
  group: SettingGroup.layout,
  label: 'Wide now playing from',
  hint: 'Windows at least this wide put the cover beside the controls.',
  defaultValue: 900,
  min: 500,
  max: 1600,
  step: 10,
  unit: 'px',
);

const showTrackNumbers = BoolSetting(
  key: 'showTrackNumbers',
  group: SettingGroup.layout,
  label: 'Show track numbers',
  hint: 'Number column at the left of track lists on a desktop layout.',
  defaultValue: true,
);

const showTrackDurations = BoolSetting(
  key: 'showTrackDurations',
  group: SettingGroup.layout,
  label: 'Show track durations',
  hint: 'Time column at the right of track lists on a desktop layout.',
  defaultValue: true,
);

const nowPlayingCover = EnumSetting<CoverStyle>(
  key: 'nowPlayingCover',
  group: SettingGroup.appearance,
  label: 'Now playing cover shape',
  hint: 'Shape of the large cover on the full screen player.',
  defaultValue: CoverStyle.arch,
  values: CoverStyle.values,
  labels: coverStyleLabels,
);

const coverRadius = IntSetting(
  key: 'coverRadius',
  group: SettingGroup.appearance,
  label: 'Cover corner radius',
  hint: 'Rounding of square covers in lists, tiles and the player bar.',
  defaultValue: 12,
  min: 0,
  max: 40,
  unit: 'px',
);

const scanExtensions = TextSetting(
  key: 'scanExtensions',
  group: SettingGroup.library,
  label: 'File types to scan',
  hint: 'Extensions the scanner picks up, separated by commas.',
  defaultValue: 'mp3, flac, m4a, aac, ogg, opus, wav',
);

const skipHiddenFolders = BoolSetting(
  key: 'skipHiddenFolders',
  group: SettingGroup.library,
  label: 'Skip hidden folders',
  hint: 'Ignore folders whose name starts with a dot.',
  defaultValue: false,
);

const followSymlinks = BoolSetting(
  key: 'followSymlinks',
  group: SettingGroup.library,
  label: 'Follow symbolic links',
  hint: 'Scan folders that are reached through links. Loops are detected.',
  defaultValue: false,
);

const excludedFolders = TextSetting(
  key: 'excludedFolders',
  group: SettingGroup.library,
  label: 'Folders to ignore',
  hint: 'Folder names the scanner skips everywhere, separated by commas.',
  defaultValue: '',
);

const coverFileNames = TextSetting(
  key: 'coverFileNames',
  group: SettingGroup.library,
  label: 'Cover file names',
  hint:
      'Picture files used as a cover when a track has none embedded, in order of preference.',
  defaultValue: 'cover.jpg, cover.png, folder.jpg',
);

const minimumTrackSeconds = IntSetting(
  key: 'minimumTrackSeconds',
  group: SettingGroup.library,
  label: 'Hide short tracks',
  hint:
      'Tracks shorter than this stay out of the library. Zero shows everything.',
  defaultValue: 0,
  min: 0,
  max: 600,
  step: 5,
  unit: 's',
);

const List<SettingDef<Object>> allSettings = [
  crossfadeSeconds,
  previousRestartSeconds,
  positionSaveSeconds,
  crossfadeCurve,
  crossfadeStepMs,
  skipUnavailableTracks,
  defaultVolume,
  maximumVolume,
  resumeOnLaunch,
  playbackSpeed,
  pitchCorrection,
  replayGain,
  audioBufferSeconds,
  seekStepSeconds,
  seekStepLongSeconds,
  textScalePercent,
  animationSpeedPercent,
  accentColor,
  rowDensity,
  rowCoverSize,
  pageMargin,
  pageMarginPhone,
  tileCoverSize,
  tileCoverSizePhone,
  sidebarExpandedWidth,
  playerBarMinHeight,
  phoneLayoutBelow,
  compactSidebarBelow,
  compactPlayerBarBelow,
  albumColumnMinWidth,
  nowPlayingWideFrom,
  showTrackNumbers,
  showTrackDurations,
  nowPlayingCover,
  coverRadius,
  scanExtensions,
  skipHiddenFolders,
  followSymlinks,
  excludedFolders,
  coverFileNames,
  minimumTrackSeconds,
];
