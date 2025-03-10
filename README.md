## About

`mediaplayer` is a lightweight media player with subtitle rendering[^subtitle] and audio track switching support, leveraging system or app-level components for seamless playback.
For API documentation, please visit [here](https://pub.dev/documentation/mediaplayer/latest/index/index-library.html).

## Flutter support

`mediaplayer` requires Flutter 3.30 or higher. For older versions, please use [av_media_player](https://pub.dev/packages/av_media_player) instead.

## Installation

1. Run the following command in your project directory:
```shell
flutter pub add mediaplayer
```
2. Add the following code to your dart file:
```dart
import 'package:mediaplayer/mediaplayer.dart';
```
3. If your project has web support, you may also need to add `mediaplayer.js` to your project by running:
```shell
dart run mediaplayer:initweb
```
4. If you met ***setState while [building](https://www.google.com/search?q=setState()+or+markNeedsBuild()+called+during+build) or [locked](https://www.google.com/search?q=setState()+or+markNeedsBuild()+called+when+widget+tree+was+locked)*** issue, then you probably need to install [`set_state_async`](https://pub.dev/packages/set_state_async) package as well.

## Platform support

| **Platform** | **Version** | **Backend**                                                                           |
| ------------ | ----------- | ------------------------------------------------------------------------------------- |
| Android      | 8+          | [ExoPlayer](https://developer.android.com/media/media3/exoplayer)                     |
| iOS          | 15+         | [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer/)          |
| macOS        | 12+         | [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer/)          |
| Windows      | 10+         | [MediaPlayer](https://learn.microsoft.com/uwp/api/windows.media.playback.mediaplayer) |
| Linux        | N/A         | [libmpv](https://github.com/mpv-player/mpv/tree/master/libmpv)[^libmpv]               |
| Web | Chrome 84+ / Safari 15+ / Firefox 90+ | [\<video>](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/video), [hls.js](https://hlsjs.video-dev.org/api-docs/)[^hlsjs], [dash.js](https://cdn.dashjs.org/latest/jsdoc/)[^dashjs] |

## Supported media formats

The supported media formats vary by platform but generally include:

| **Type**          | **Formats**                                        |
| ----------------- | -------------------------------------------------- |
| Video Codec       | H.264, H.265(HEVC)[^h265], AV1                     |
| Audio Codec       | AAC, MP3                                           |
| Container Format  | MP4, TS, webm[^avplayer]                           |
| Subtitle Format   | WebVTT[^vtt], CEA-608/708[^cea]                    |
| Transfer Protocol | HTTP, HLS, LL-HLS, DASH[^avplayer], MSS[^avplayer] |

[^subtitle]: Only internal subtitle tracks are supported.
[^libmpv]: Linux backend requires `libmpv`(aka `mpv-libs`). Developers integrating this plugin into Linux app should install `libmpv-dev`(aka `mpv-libs-devel`) instead. If unavailable in your package manager, please build `libmpv` from source. For details refer to [mpv-build](https://github.com/mpv-player/mpv-build).
[^hlsjs]: `hls.js` is used for playing HLS on all web platforms except Safari. Which has native HLS support.
[^dashjs]: `dash.js` is used for playing DASH and MSS on all web platforms except iOS 17.1-. Which has no MSE support.
[^h265]: Windows user may need to install a free [H.265 decoder](https://apps.microsoft.com/detail/9n4wgh0z6vhq) from Microsoft Store. Web platforms may lack H.265 support except for Safari.
[^avplayer]: DASH, MSS and webm are not supported on iOS and macOS.
[^vtt]: Linux backend does not support WebVTT subtitles within HLS.
[^cea]: CEA-608/708 subtitles are not supported on web platforms.