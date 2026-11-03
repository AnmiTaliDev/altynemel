class Strings {
  static const appName = 'Altynemel';
  static const play = 'Play';
  static const pause = 'Pause';
  static const previousTrack = 'Previous track';
  static const nextTrack = 'Next track';
  static const playPauseShortcut = 'Play or pause';
  static const playNext = 'Play next';
  static const addToQueue = 'Add to queue';
  static const addToPlaylist = 'Add to playlist';
  static const newPlaylist = 'New playlist';
  static const playlistName = 'Playlist name';
  static const createPlaylist = 'Create';
  static const showInFolder = 'Show in folder';
  static const closeMenu = 'Close menu';
  static const back = 'Back';
  static const noPlaylists = 'No playlists yet';
  static String menuFor(String title) => 'Actions for $title';
  static String withShortcut(String label, String keys) => '$label ($keys)';
  static const shuffle = 'Shuffle';
  static const repeat = 'Repeat';
  static const repeatAll = 'Repeat all';
  static const repeatOne = 'Repeat one';
  static const addToFavorites = 'Add to favorites';
  static const removeFromFavorites = 'Remove from favorites';
  static const search = 'Search';
  static const playlists = 'Playlists';
  static const playlist = 'Playlist';
  static const nowPlaying = 'Now playing';
  static const library = 'Library';
  static const queue = 'Queue';
  static const settings = 'Settings';
  static const volume = 'Volume';
  static const seek = 'Seek';
  static const coverUnavailable = 'Cover art unavailable';
  static const unavailableOffline = 'Unavailable offline';
  static const downloaded = 'Downloaded';
  static const playingNow = 'Playing now';
  static const mainNavigation = 'Main navigation';
  static const player = 'Player';
  static const columnNumber = '#';
  static const columnTitle = 'Title';
  static const columnAlbum = 'Album';
  static const columnTime = 'Time';
  static const about = 'About';
  static const aboutApp = 'About Altynemel';
  static const aboutText =
      'Altynemel is a desktop music player for audio files from a local folder.';
  static const aboutFreeSoftware = 'About free software';
  static const aboutFreeSoftwareHint =
      'Licenses of Altynemel and of the software it uses.';
  static const freeSoftwareIntro =
      'Altynemel is free software. You may use, study, share and change it under the terms of the GNU General Public License, version 3 only. It comes with no warranty.';
  static const fontName = 'Onest';
  static const versionLabel = 'Version';
  static const licenseLabel = 'License';
  static const loadingLicenses = 'Loading licenses';
  static const licensesFailed = 'Licenses could not be loaded.';
  static String licenseCount(int count) =>
      count == 1 ? '1 component' : '$count components';
  static const deletePlaylist = 'Delete playlist';
  static const removeFromPlaylist = 'Remove from playlist';
  static const cancel = 'Cancel';
  static const deletePlaylistHint = 'The tracks stay in your library.';
  static String deletePlaylistQuestion(String name) => 'Delete $name?';
  static String goToArtist(String name) => 'Go to $name';
  static String goToAlbum(String name) => 'Go to album $name';
  static const removeFromQueue = 'Remove from queue';
  static String removeTrackFromQueue(String title) =>
      'Remove $title from queue';
  static const collapse = 'Collapse';
  static const openNowPlaying = 'Open now playing';
  static const albumKind = 'Album';
  static const artistKind = 'Artist';
  static const albums = 'Albums';
  static const artists = 'Artists';
  static const tracks = 'Tracks';
  static const libraryViews = 'Library view';
  static const libraryEmpty = 'No music yet';
  static const libraryEmptyHint =
      'Choose a library folder in Settings to add music.';
  static const openSettings = 'Open settings';
  static const queueEmpty = 'The queue is empty';
  static const queueEmptyHint = 'Play a track from the library to fill it.';
  static const nextUp = 'Next up';
  static const appearance = 'Appearance';
  static const playback = 'Playback';
  static const theme = 'Theme';
  static const themeHint = 'Follow the system or pick one theme.';
  static const themeSystem = 'System';
  static const themeNight = 'Night';
  static const themeDay = 'Day';
  static const themeContrast = 'Contrast';
  static const reduceMotion = 'Reduce motion';
  static const reduceMotionHint = 'Replace transitions with instant changes.';
  static const gapless = 'Gapless playback';
  static const gaplessHint = 'Play consecutive tracks without a pause.';
  static const crossfade = 'Crossfade';
  static const crossfadeHint = 'Blend the end of a track into the next one.';
  static const volumeStep = 'Volume step';
  static const volumeStepHint = 'Change per key press, in percent.';
  static const libraryFolder = 'Library folder';
  static const libraryFolderNone = 'No folder chosen.';
  static const chooseFolder = 'Choose folder';
  static const unavailableInBuild = 'Unavailable in this build.';
  static const rescan = 'Rescan';
  static const rescanHint = 'How often the folder is checked for changes.';
  static const minutes5 = '5 minutes';
  static const minutes15 = '15 minutes';
  static const hour1 = '1 hour';
  static const hours6 = '6 hours';
  static const rescanOff = 'Never';
  static const splitArtists = 'Split artists';
  static const splitArtistsHint =
      'Treat commas, semicolons and feat. as separators.';
  static const albumOrder = 'Album order';
  static const albumOrderHint = 'How tracks inside an album are sorted.';
  static const orderDiscTrack = 'Disc and track';
  static const orderFileName = 'File name';
  static const selected = 'Selected';
  static const minimize = 'Minimize';
  static const maximize = 'Maximize';
  static const advancedSettings = 'Advanced settings';
  static const advancedSettingsHint =
      'Fine tuning of playback, sound, appearance, layout and the library.';
  static const openAdvancedSettings = 'Open advanced settings';
  static const resetSetting = 'Reset';
  static String resetSettingLabel(String title) => 'Reset $title';
  static const resetAllSettings = 'Reset all';
  static const resetAllQuestion = 'Reset all advanced settings?';
  static const resetAllHint = 'Every value goes back to its default.';
  static const searchSettings = 'Search settings';
  static const noSettingsFound = 'No settings match';
  static const noSettingsFoundHint = 'Try another word.';
  static const modifiedMark = 'Changed';
  static const copySettings = 'Copy settings';
  static const pasteSettings = 'Paste settings';
  static const settingsCopied = 'Copied to the clipboard.';
  static const settingsPasted = 'Settings applied.';
  static const settingsPasteFailed = 'The clipboard has no valid settings.';
  static const setupWelcomeTitle = 'Welcome to Altynemel';
  static const setupWelcomeBody =
      'A few quick choices to set the player up. It takes about a minute and every choice can be changed later in Settings.';
  static const setupWelcomeLook = 'Pick a look';
  static const setupWelcomeMusic = 'Point it at your music';
  static const setupWelcomePlayback = 'Tune the playback';
  static const setupAppearanceTitle = 'Choose how it looks';
  static const setupAppearanceHint =
      'The preview is live. Pick a design style, a theme and an accent color.';
  static const setupStyleLabel = 'Design style';
  static const setupStyleAltynemel = 'Altynemel';
  static const setupStyleAltynemelHint =
      'Quiet and sharp, with thin outlines and a calm palette.';
  static const setupStyleMaterial = 'Material 3';
  static const setupStyleMaterialHint =
      'Google design system with tonal colors, rounded shapes and state layers.';
  static const setupThemeLabel = 'Theme';
  static const setupAccentLabel = 'Accent color';
  static const setupPreviewLabel = 'Preview';
  static const setupPreviewTrack = 'Fading memories';
  static const setupPreviewArtist = 'June Lu';
  static const setupPreviewPlay = 'Play';
  static const setupPreviewQueue = 'Add to queue';
  static const setupLibraryTitle = 'Add your music';
  static const setupLibraryHint =
      'Choose the folder that holds your music. The app scans it in the background and keeps it up to date.';
  static const setupLibraryNone = 'No folder selected yet.';
  static String setupLibraryChosen(String path) => 'Selected: $path';
  static const setupLibraryChoose = 'Choose folder';
  static const setupLibraryChange = 'Change folder';
  static const setupLibraryLater =
      'You can skip this and add a folder later in Settings.';
  static const setupAccessAllow = 'Allow access to audio files';
  static const setupAccessGranted = 'Access to audio files is allowed.';
  static const setupAccessDenied =
      'Access was not granted. Allow it in the system settings to see your music.';
  static const setupPlaybackTitle = 'Set up playback';
  static const setupPlaybackHint =
      'Basic playback behavior. Many more options live in the advanced settings.';
  static const setupNormalization = 'Volume normalization';
  static const setupNormalizationHint =
      'Even out the loudness of tracks that carry ReplayGain tags.';
  static const setupResume = 'Resume where you left off';
  static const setupResumeHint =
      'Start playing the last track right after the app opens.';
  static const setupFinishTitle = 'You are all set';
  static const setupFinishHint =
      'This is what you chose. Everything can be changed later in Settings.';
  static const setupSummaryStyle = 'Design style';
  static const setupSummaryTheme = 'Theme';
  static const setupSummaryAccent = 'Accent color';
  static const setupSummaryLibrary = 'Music folder';
  static const setupSummaryPlayback = 'Playback';
  static const setupSummaryNoFolder = 'Not chosen';
  static const setupSummaryGaplessOn = 'Gapless';
  static const setupSummaryGaplessOff = 'Gaps between tracks';
  static String setupSummaryCrossfade(int seconds) => 'Crossfade $seconds s';
  static const setupSummaryNoCrossfade = 'No crossfade';
  static String setupSummaryNormalization(String mode) =>
      'Normalization: $mode';
  static const setupNext = 'Next';
  static const setupBack = 'Back';
  static const setupSkip = 'Skip';
  static const setupFinish = 'Start listening';
  static const setupStepsLabel = 'Setup progress';
  static String setupStepOf(int step, int total) => 'Step $step of $total';
  static const setupRunAgain = 'Run the setup again';
  static const setupRunAgainHint =
      'Walk through the first run choices once more.';
  static const setupSkipAll = 'Skip setup';
  static const setupStepWelcome = 'Welcome';
  static const setupStepAppearance = 'Look';
  static const setupStepLibrary = 'Music';
  static const setupStepPlayback = 'Playback';
  static const setupStepFinish = 'Done';
  static const restore = 'Restore';
  static const closeWindow = 'Close';
  static const nothingPlaying = 'Nothing playing';
  static const nothingPlayingHint = 'Play a track to see its list here.';
  static const scanning = 'Scanning library';
  static const folderUnavailable = 'The library folder is not available.';
  static const scanFailed = 'Scan failed';
  static const liked = 'Liked';
  static const likedEmpty = 'No liked tracks yet';
  static const likedEmptyHint =
      'Use the heart in the player bar to like a track.';
  static const noResults = 'No matches';
  static const noResultsHint = 'Try another search.';
  static const dropFolderHint = 'You can also drop a folder onto the window.';

  static String coverOf(String album) => 'Cover art: $album';
  static String moreAbout(String title) => 'More about $title';
  static String nowPlayingCard(String title, String artist) =>
      'Now playing: $title, $artist';
  static String songsIn(String playlist) => 'Songs in $playlist';
  static String percent(int value) => '$value percent';
  static String songCount(int count) => count == 1 ? '1 song' : '$count songs';
  static String tracksOf(int count) => count == 1 ? '1 track' : '$count tracks';
  static String albumTile(String title, String artist) => '$title, $artist';
  static String artistTile(String name, int count) =>
      '$name, ${tracksOf(count)}';
}
