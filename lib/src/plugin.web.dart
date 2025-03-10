import 'dart:js_interop';
import 'dart:ui_web';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

@JS()
extension type MediaplayerPlugin._(JSObject _) implements JSObject {
  static var _nextId = 0;
  static final _instances = <int, MediaplayerPlugin>{};

  static MediaplayerPlugin create(JSFunction onmessage) {
    final instance = MediaplayerPlugin(onmessage);
    instance.id = _nextId++;
    _instances[instance.id] = instance;
    return instance;
  }

  static void destroy(MediaplayerPlugin instance) =>
      _instances.remove(instance.id);

  static void registerWith(Registrar registrar) =>
      platformViewRegistry.registerViewFactory(
        'mediaplayer',
        (int viewId, {Object? params}) => _instances[params as int]!.dom,
      );

  external MediaplayerPlugin(JSFunction onmessage);
  external int id;
  external JSObject get dom;
  external void play();
  external void pause();
  external void open(String source);
  external void close();
  external void seekTo(int position, bool fast);
  external void setVolume(double volume);
  external void setSpeed(double speed);
  external void setLooping(bool looping);
  external void setAutoPlay(bool autoPlay);
  external void setMaxResolution(int width, int height);
  external void setMaxBitRate(int bitrate);
  external void setPreferredAudioLanguage(String language);
  external void setPreferredSubtitleLanguage(String language);
  external void setShowSubtitle(bool show);
  external bool setFullscreen(bool fullscreen);
  external bool setPictureInPicture(bool pictureInPicture);
  external void setOverrideAudio(String? trackId);
  external void setOverrideSubtitle(String? trackId);
  external void setBackgroundColor(int color);
  external void setVideoFit(String objectFit);
}
