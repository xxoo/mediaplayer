import 'dart:js_interop';
import 'dart:ui_web';
import 'package:flutter/widgets.dart';
import 'player.common.dart';
import 'player.interface.dart';
import 'plugin.web.dart';

/// Web implementation of [MediaplayerInterface].
class Mediaplayer extends MediaplayerInterface {
  @override
  get disposed => _disposed;
  var _disposed = false;

  @override
  get id => _plugin.id;
  late final MediaplayerPlugin _plugin;

  String? _source;
  var _seeking = false;
  var _loading = false;

  Mediaplayer({
    String? initSource,
    double? initVolume,
    double? initSpeed,
    bool? initLooping,
    bool? initAutoPlay,
    int? initPosition,
    bool? initShowSubtitle,
    String? initPreferredSubtitleLanguage,
    String? initPreferredAudioLanguage,
    int? initMaxBitRate,
    Size? initMaxResolution,
  }) {
    _plugin = MediaplayerPlugin.create(
      (JSObject message) {
        final e = message.dartify() as Map;
        if (e['event'] == 'error') {
          // ignore errors when player is closed
          if (playbackState.value != PlaybackState.closed || loading.value) {
            _source = null;
            error.value = e['value'];
            loading.value = false;
            _close();
          }
        } else if (e['event'] == 'mediaInfo') {
          if (_source != null && _translateSource(_source!) == e['source']) {
            loading.value = false;
            playbackState.value = PlaybackState.paused;
            mediaInfo.value = MediaInfo(
              (e['duration'] as double).toInt(),
              (e['audioTracks'] as Map).map(
                (k, v) => MapEntry(k as String, AudioInfo.fromMap(v as Map)),
              ),
              (e['subtitleTracks'] as Map).map(
                (k, v) => MapEntry(k as String, SubtitleInfo.fromMap(v as Map)),
              ),
              _source!,
            );
            if (mediaInfo.value!.duration == 0) {
              speed.value = 1;
            }
          }
        } else if (e['event'] == 'videoSize') {
          if (playbackState.value != PlaybackState.closed || loading.value) {
            final width = e['width'] as double;
            final height = e['height'] as double;
            if (width != videoSize.value.width ||
                height != videoSize.value.height) {
              videoSize.value =
                  width > 0 && height > 0 ? Size(width, height) : Size.zero;
            }
          }
        } else if (e['event'] == 'position') {
          if (mediaInfo.value != null) {
            final v = (e['value'] as double).toInt();
            position.value =
                v > mediaInfo.value!.duration
                    ? mediaInfo.value!.duration
                    : v < 0
                    ? 0
                    : v;
          }
        } else if (e['event'] == 'buffer') {
          if (mediaInfo.value != null) {
            final start = (e['start'] as double).toInt();
            final end = (e['end'] as double).toInt();
            bufferRange.value =
                start == 0 && end == 0
                    ? BufferRange.empty
                    : BufferRange(start, end);
          }
        } else if (e['event'] == 'finished') {
          if (mediaInfo.value != null) {
            finishedTimes.value += 1;
            loading.value = false;
            if (mediaInfo.value!.duration == 0) {
              _close();
            } else if (!looping.value) {
              playbackState.value = PlaybackState.paused;
            }
          }
        } else if (e['event'] == 'playing') {
          if (mediaInfo.value != null) {
            loading.value = _seeking = _loading = false;
            playbackState.value =
                e['value'] ? PlaybackState.playing : PlaybackState.paused;
          }
        } else if (e['event'] == 'loading') {
          if (mediaInfo.value != null) {
            _loading = e['value'];
            loading.value = _loading || _seeking;
          }
        } else if (e['event'] == 'seeking') {
          if (mediaInfo.value != null) {
            _seeking = e['value'];
            loading.value = _loading || _seeking;
          }
        } else if (e['event'] == 'speed') {
          speed.value = e['value'];
        } else if (e['event'] == 'volume') {
          volume.value = e['value'];
        } else if (e['event'] == 'fullscreen') {
          fullscreen.value = e['value'];
        } else if (e['event'] == 'pictureInPicture') {
          pictureInPicture.value = e['value'];
        } else if (e['event'] == 'showSubtitle') {
          showSubtitle.value = e['value'];
        } else if (e['event'] == 'overrideAudio') {
          _overrideTrack(e['id'], true);
        } else if (e['event'] == 'overrideSubtitle') {
          _overrideTrack(e['id'], false);
        }
      }.toJS,
    );
    if (initSource != null) {
      open(initSource);
      if (initPosition != null) {
        seekTo(initPosition);
      }
    }
    if (initVolume != null) {
      setVolume(initVolume);
    }
    if (initSpeed != null) {
      setSpeed(initSpeed);
    }
    if (initLooping != null) {
      setLooping(initLooping);
    }
    if (initAutoPlay != null) {
      setAutoPlay(initAutoPlay);
    }
    if (initMaxBitRate != null) {
      setMaxBitRate(initMaxBitRate);
    }
    if (initMaxResolution != null) {
      setMaxResolution(initMaxResolution);
    }
    if (initPreferredAudioLanguage != null) {
      setPreferredAudioLanguage(initPreferredAudioLanguage);
    }
    if (initPreferredSubtitleLanguage != null) {
      setPreferredSubtitleLanguage(initPreferredSubtitleLanguage);
    }
    if (initShowSubtitle != null) {
      setShowSubtitle(initShowSubtitle);
    }
  }

  @override
  void dispose() {
    if (!disposed) {
      _disposed = true;
      MediaplayerPlugin.destroy(_plugin);
      _plugin.close();
      mediaInfo.dispose();
      videoSize.dispose();
      position.dispose();
      error.dispose();
      loading.dispose();
      playbackState.dispose();
      volume.dispose();
      speed.dispose();
      looping.dispose();
      autoPlay.dispose();
      finishedTimes.dispose();
      bufferRange.dispose();
      maxBitRate.dispose();
      maxResolution.dispose();
      preferredAudioLanguage.dispose();
      preferredSubtitleLanguage.dispose();
      showSubtitle.dispose();
      overrideAudio.dispose();
      overrideSubtitle.dispose();
    }
  }

  @override
  void close() {
    if (!disposed) {
      _source = null;
      if (playbackState.value != PlaybackState.closed || loading.value) {
        _plugin.close();
        _close();
      }
      loading.value = false;
    }
  }

  @override
  void open(String source) {
    if (!disposed) {
      _source = source;
      error.value = null;
      _close();
      _plugin.open(_translateSource(source));
      loading.value = true;
    }
  }

  @override
  bool play() {
    if (!disposed) {
      if (playbackState.value == PlaybackState.paused) {
        _plugin.play();
        return true;
      } else if (!autoPlay.value &&
          playbackState.value == PlaybackState.closed &&
          _source != null) {
        setAutoPlay(true);
        return true;
      }
    }
    return false;
  }

  @override
  bool pause() {
    if (!disposed) {
      if (playbackState.value == PlaybackState.playing) {
        _plugin.pause();
        return true;
      } else if (autoPlay.value &&
          playbackState.value == PlaybackState.closed &&
          _source != null) {
        setAutoPlay(false);
        return true;
      }
    }
    return false;
  }

  @override
  bool seekTo(int value, {bool fast = false}) {
    if (!disposed) {
      if (mediaInfo.value == null) {
        // ignore initPosition if it's less than 30 ms
        if (loading.value && value > 30) {
          _plugin.seekTo(value, true);
          return true;
        }
      } else if (mediaInfo.value!.duration > 0) {
        if (value < 0) {
          value = 0;
        } else if (value > mediaInfo.value!.duration) {
          value = mediaInfo.value!.duration;
        }
        _plugin.seekTo(value, fast);
        return true;
      }
    }
    return false;
  }

  @override
  bool setAutoPlay(bool value) {
    if (!disposed && value != autoPlay.value) {
      autoPlay.value = value;
      _plugin.setAutoPlay(value);
      return true;
    }
    return false;
  }

  @override
  bool setLooping(bool value) {
    if (!disposed && value != looping.value) {
      looping.value = value;
      _plugin.setLooping(value);
      return true;
    }
    return false;
  }

  @override
  bool setShowSubtitle(bool value) {
    if (!disposed && value != showSubtitle.value) {
      showSubtitle.value = value;
      _plugin.setShowSubtitle(value);
      return true;
    }
    return false;
  }

  @override
  bool setSpeed(double value) {
    if (!disposed && mediaInfo.value?.duration != 0) {
      _plugin.setSpeed(value);
      return true;
    }
    return false;
  }

  @override
  bool setVolume(double value) {
    if (!disposed) {
      _plugin.setVolume(value);
      return true;
    }
    return false;
  }

  @override
  bool setMaxBitRate(int value) {
    if (!disposed && value >= 0 && value != maxBitRate.value) {
      maxBitRate.value = value;
      _plugin.setMaxBitRate(value);
    }
    return false;
  }

  @override
  bool setMaxResolution(Size value) {
    if (!disposed &&
        value.width >= 0 &&
        value.height >= 0 &&
        (value.width != maxResolution.value.width ||
            value.height != maxResolution.value.height)) {
      maxResolution.value = value;
      _plugin.setMaxResolution(value.width.toInt(), value.height.toInt());
    }
    return false;
  }

  @override
  bool setPreferredAudioLanguage(String? value) {
    if (!disposed && value != preferredAudioLanguage.value) {
      preferredAudioLanguage.value = value;
      _plugin.setPreferredAudioLanguage(value ?? '');
      return true;
    }
    return false;
  }

  @override
  bool setPreferredSubtitleLanguage(String? value) {
    if (!disposed && value != preferredSubtitleLanguage.value) {
      preferredSubtitleLanguage.value = value;
      _plugin.setPreferredSubtitleLanguage(value ?? '');
      return true;
    }
    return false;
  }

  @override
  bool setOverrideAudio(String? trackId) {
    if (!disposed) {
      final result = _overrideTrack(trackId, true);
      if (result) {
        _plugin.setOverrideAudio(trackId);
      }
      return result;
    }
    return false;
  }

  @override
  bool setOverrideSubtitle(String? trackId) {
    if (!disposed) {
      final result = _overrideTrack(trackId, false);
      if (result) {
        _plugin.setOverrideSubtitle(trackId);
      }
      return result;
    }
    return false;
  }

  @override
  bool setFullscreen(bool value) {
    if (!disposed && videoSize.value != Size.zero) {
      return _plugin.setFullscreen(value);
    }
    return false;
  }

  @override
  bool setPictureInPicture(bool value) {
    if (!disposed && videoSize.value != Size.zero) {
      return _plugin.setPictureInPicture(value);
    }
    return false;
  }

  /// Set the background color of the player.
  /// This API is only available on web and should be considered as private.
  void setBackgroundColor(Color color) {
    if (!disposed) {
      _plugin.setBackgroundColor(color.toARGB32());
    }
  }

  /// Set the content fit of the player.
  /// This API is only available on web and should be considered as private.
  void setVideoFit(BoxFit fit) {
    if (!disposed) {
      _plugin.setVideoFit(fit.toString().split('.').last);
    }
  }

  bool _overrideTrack(String? trackId, bool isAudio) {
    if (mediaInfo.value != null) {
      final ValueNotifier<String?> overrided;
      final Map<String, Object> tracks;
      if (isAudio) {
        tracks = mediaInfo.value!.audioTracks;
        overrided = overrideAudio;
      } else {
        tracks = mediaInfo.value!.subtitleTracks;
        overrided = overrideSubtitle;
      }
      if (trackId != overrided.value &&
          (trackId == null || tracks.containsKey(trackId))) {
        overrided.value = trackId;
        return true;
      }
    }
    return false;
  }

  void _close() {
    _seeking = _loading = false;
    mediaInfo.value = null;
    videoSize.value = Size.zero;
    position.value = 0;
    bufferRange.value = BufferRange.empty;
    finishedTimes.value = 0;
    playbackState.value = PlaybackState.closed;
    overrideAudio.value = overrideSubtitle.value = null;
  }
}

String _translateSource(String asset) {
  if (asset.startsWith('asset://')) {
    return AssetManager().getAssetUrl(asset.substring(8));
  }
  return asset;
}
