enum CrossfadeCurve { equalPower, linear }

const crossfadeCurveLabels = {
  CrossfadeCurve.equalPower: 'Equal power',
  CrossfadeCurve.linear: 'Linear',
};

enum ReplayGainMode {
  off('no'),
  track('track'),
  album('album');

  const ReplayGainMode(this.mpvValue);

  final String mpvValue;
}

const replayGainLabels = {
  ReplayGainMode.off: 'Off',
  ReplayGainMode.track: 'Track',
  ReplayGainMode.album: 'Album',
};

enum AccentChoice { theme, mint, sky, amber, rose, violet }

const accentLabels = {
  AccentChoice.theme: 'Theme default',
  AccentChoice.mint: 'Mint',
  AccentChoice.sky: 'Sky',
  AccentChoice.amber: 'Amber',
  AccentChoice.rose: 'Rose',
  AccentChoice.violet: 'Violet',
};

enum RowDensity { compact, comfortable, spacious }

const rowDensityLabels = {
  RowDensity.compact: 'Compact',
  RowDensity.comfortable: 'Comfortable',
  RowDensity.spacious: 'Spacious',
};

const rowDensityHeights = {
  RowDensity.compact: 44.0,
  RowDensity.comfortable: 56.0,
  RowDensity.spacious: 72.0,
};

enum CoverStyle { arch, square, circle }

const coverStyleLabels = {
  CoverStyle.arch: 'Arch',
  CoverStyle.square: 'Square',
  CoverStyle.circle: 'Circle',
};

enum ArtistSort { name, trackCount }

const artistSortLabels = {
  ArtistSort.name: 'Name',
  ArtistSort.trackCount: 'Most tracks first',
};

enum AlbumSort { title, artist, trackCount }

const albumSortLabels = {
  AlbumSort.title: 'Title',
  AlbumSort.artist: 'Artist',
  AlbumSort.trackCount: 'Most tracks first',
};

enum DesignStyle { altynemel, material }

const designStyleLabels = {
  DesignStyle.altynemel: 'Altynemel',
  DesignStyle.material: 'Material 3',
};
