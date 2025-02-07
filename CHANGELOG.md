## 1.3.0 & 1.2.3 & 1.1.7
- architecture upgrade, and add web support. (wasm compatible)
- v1.3.x provides better performance than 1.2.x on android, but requires flutter 3.29 or higher.
- **breaking change:** file structure adjustment, no longer support high-granularity import. now the only entry is `index.dart`.
- **breaking change:** replace `sizingMode` with `videoFit` in `MediaplayerView` class.
- **breaking change:** replace `overrideTracks` with `overrideVideo`, `overrideAudio` and `overrideSubtitle` in `Mediaplayer` class.