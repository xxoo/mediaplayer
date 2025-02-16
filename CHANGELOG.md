## 1.3.0
- architecture upgrade, and add web support. (wasm compatible)
- v1.3 provides better performance than 1.2 on android, but requires flutter 3.29 or higher.
- support fast seek on all platforms except chrome and windows.
- **braaking change:** removed video tracks from `MediaInfo.tracks` since they're not supported on many platforms. which means it's no longer possible to switch video tracks via `overrideTracks()`. however, `setMaxResolution()` and `setMaxBitrate()` are still available.
- **breaking change:** file structure adjustment, no longer support high-granularity import. now the only entry is `index.dart`.
- **breaking change:** replace `sizingMode` with `videoFit` in `MediaplayerView` class.
- **breaking change:** replace `overrideTracks` with `overrideVideo`, `overrideAudio` and `overrideSubtitle` in `Mediaplayer` class.