## 1.3.0
- architecture upgrade, and add web support. (wasm compatible)
- v1.3 provides better performance than v1.2 on android, but requires flutter 3.29 or higher.
- support fast seek on all platforms except chrome and windows.
- **breaking change:** replace `sizingMode` with `videoFit` in `MediaplayerView` class.
- **braaking change:** removed video tracks from `MediaInfo.tracks` since they're not supported on many platforms. which means it's no longer possible to switch video tracks via `overrideTrack()`. however, `setMaxResolution()` and `setMaxBitrate()` are still available.
- **breaking change:** file structure adjustment, no longer support high-granularity import. now the only entry is `index.dart`.
- **breaking change:** replace `overrideTracks` with `overrideAudio` and `overrideSubtitle` in `Mediaplayer` class.
- **breaking change:** replace `overrideTrack()` with `setOverrideAudio()` and `setOverrideSubtitle()` in `Mediaplayer` class.