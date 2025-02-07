## About

mediaplayer is a lightweight media player with subtitle rendering[^subtitle] and track selection support, leveraging system or app-level components for seamless playback.
For API documentation, please visit [here](https://pub.dev/documentation/mediaplayer/latest/index/index-library.html).

## Platform support

| **Platform** | **Version** | **Backend**                                                                           |
| ------------ | ----------- | ------------------------------------------------------------------------------------- |
| Android      | 8+          | [ExoPlayer](https://developer.android.com/media/media3/exoplayer)                     |
| iOS          | 15+         | [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer/)          |
| macOS        | 12+         | [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer/)          |
| Windows      | 10+         | [MediaPlayer](https://learn.microsoft.com/uwp/api/windows.media.playback.mediaplayer) |
| Linux        | N/A         | [libmpv](https://github.com/mpv-player/mpv/tree/master/libmpv)[^libmpv]               |
| Web | Chrome 84+ / Safari 15+ / Firefox 90+ | [\<video>](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/video), [hls.js](https://hlsjs.video-dev.org/api-docs/)[^hlsjs], [dash.js](https://cdn.dashjs.org/latest/jsdoc/)[^dashjs] |

## Flutter support

| **Flutter** | **mediaplayer** | **Difference**                                      |
| ----------- | --------------- | --------------------------------------------------- |
| 3.28+       | 1.3+            | Supports Impeller on Android                        |
| 3.27        | 1.2             | Supports Impeller on Android with performance issue |
| 3.19 - 3.24 | 1.1             | Does not support Impeller on Android                |

## Installation
Run this command in your project directory:
```shell
flutter pub add mediaplayer
```
If your project has web support, you may also need to add `mediaplayer.js` by running:
```shell
dart run mediaplayer:initweb
```

## Supported media formats

The supported media formats vary by platform but generally include:

| **Type**          | **Formats**               |
| ----------------- | ------------------------- |
| Video Codec       | H.264, H.265(HEVC)[^h265] |
| Audio Codec       | AAC, MP3                  |
| Container Format  | MP4, TS                   |
| Subtitle Format   | WebVTT[^webvtt]           |
| Transfer Protocol | HTTP, HLS, LL-HLS         |

[^subtitle]: Only internal subtitle tracks are supported.
[^libmpv]: The Linux backend requires `libmpv`(aka `mpv-libs`). Developers integrating this plugin into Linux app should install `libmpv-dev`(aka `mpv-libs-devel`) instead. If unavailable in your package manager, please build `libmpv` from source. For details, please refer to [mpv-build](https://github.com/mpv-player/mpv-build).
[^hlsjs]: hls.js is used on all web platforms except Safari. Which has native HLS support.
[^dashjs]: dash.js is used on all web platforms except iOS 17.0-. Which has no MSE support.
[^h265]: Windows user may need to install a free [H.265 decoder](https://apps.microsoft.com/detail/9n4wgh0z6vhq) from Microsoft Store. Web platforms may lack H.265 support except for Safari. But those platforms should have AV1/webm/dash.js support as an alternative.
[^webvtt]: WebVTT is supported on all platforms except Linux, where SRT and ASS formats are supported instead.
