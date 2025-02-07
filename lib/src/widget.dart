import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widget.web.dart' if (dart.library.io) 'widget.native.dart';
import 'player.web.dart' if (dart.library.io) 'player.native.dart';

/// This mixin is used by [MediaplayerView] to avoid [setState] issues.
///
/// It is recommended to add this mixin in your [StatefulWidget]'s [State] class
/// while using [Mediaplayer] or [MediaplayerView].
mixin SetStateAsync<T extends StatefulWidget> on State<T> {
  final _fns = <VoidCallback>[];
  void _runFns() {
    for (final fn in _fns) {
      fn();
    }
    _fns.clear();
  }

  /// Combine all [setState] calls within the same tick into single one.
  /// This also makes the [setState] opearation async.
  @override
  void setState(VoidCallback fn) {
    if (_fns.isEmpty) {
      Future.microtask(() {
        if (mounted) {
          super.setState(_runFns);
        }
      });
    }
    _fns.add(fn);
  }
}

/// The widget to display video for [Mediaplayer].
class MediaplayerView extends StatefulWidget {
  final Mediaplayer? initPlayer;
  final void Function(Mediaplayer player)? onCreated;
  final Color backgroundColor;
  final BoxFit videoFit;
  final String? initSource;
  final bool? initAutoPlay;
  final bool? initLooping;
  final double? initVolume;
  final double? initSpeed;
  final int? initPosition;
  final bool? initShowSubtitle;
  final String? initPreferredSubtitleLanguage;
  final String? initPreferredAudioLanguage;
  final int? initMaxBitRate;
  final Size? initMaxResolution;

  /// Create a new [MediaplayerView] widget.
  /// If [initPlayer] is null, a new player will be created.
  /// You can get the player from [onCreated] callback.
  ///
  /// [backgroundColor] is the color behind the video.
  /// This parameter can be changed by updating the widget.
  ///
  /// [videoFit] determines how the video is displayed.
  /// This parameter can be changed by updating the widget.
  ///
  /// Other parameters only take efferts at the time the widget is mounted.
  /// To changed them later, you need to call the corresponding methods of the player.
  const MediaplayerView({
    super.key,
    this.initPlayer,
    this.initSource,
    this.initAutoPlay,
    this.initLooping,
    this.initVolume,
    this.initSpeed,
    this.initPosition,
    this.initShowSubtitle,
    this.initPreferredSubtitleLanguage,
    this.initPreferredAudioLanguage,
    this.initMaxBitRate,
    this.initMaxResolution,
    this.onCreated,
    this.backgroundColor = Colors.black,
    this.videoFit = BoxFit.contain,
  });

  @override
  State<MediaplayerView> createState() => _AVMediaState();
}

class _AVMediaState extends State<MediaplayerView> with SetStateAsync {
  late final Mediaplayer _player;
  bool _foreignPlayer = false;
  // This is a workaround for the fullscreen issue on web.
  OverlayEntry? _overlayEntry;

  void _fullscreenChange() {
    if (_player.fullscreen.value) {
      if (_overlayEntry == null) {
        _overlayEntry = OverlayEntry(
          builder:
              (context) => Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
        );
        Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
      }
    } else {
      _clearOverlay();
    }
  }

  void _clearOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    if (widget.initPlayer == null || widget.initPlayer!.disposed) {
      _player = Mediaplayer(
        initSource: widget.initSource,
        initAutoPlay: widget.initAutoPlay,
        initLooping: widget.initLooping,
        initVolume: widget.initVolume,
        initSpeed: widget.initSpeed,
        initPosition: widget.initPosition,
        initShowSubtitle: widget.initShowSubtitle,
        initPreferredSubtitleLanguage: widget.initPreferredSubtitleLanguage,
        initPreferredAudioLanguage: widget.initPreferredAudioLanguage,
        initMaxBitRate: widget.initMaxBitRate,
        initMaxResolution: widget.initMaxResolution,
      );
    } else {
      _player = widget.initPlayer!;
      _foreignPlayer = true;
      if (widget.initSource != null) {
        _player.open(widget.initSource!);
      }
      if (widget.initAutoPlay != null) {
        _player.setAutoPlay(widget.initAutoPlay!);
      }
      if (widget.initLooping != null) {
        _player.setLooping(widget.initLooping!);
      }
      if (widget.initVolume != null) {
        _player.setVolume(widget.initVolume!);
      }
      if (widget.initSpeed != null) {
        _player.setSpeed(widget.initSpeed!);
      }
      if (widget.initPosition != null) {
        _player.seekTo(widget.initPosition!);
      }
      if (widget.initShowSubtitle != null) {
        _player.setShowSubtitle(widget.initShowSubtitle!);
      }
      if (widget.initPreferredSubtitleLanguage != null) {
        _player.setPreferredSubtitleLanguage(
          widget.initPreferredSubtitleLanguage!,
        );
      }
      if (widget.initPreferredAudioLanguage != null) {
        _player.setPreferredAudioLanguage(widget.initPreferredAudioLanguage!);
      }
      if (widget.initMaxBitRate != null) {
        _player.setMaxBitRate(widget.initMaxBitRate!);
      }
      if (widget.initMaxResolution != null) {
        _player.setMaxResolution(widget.initMaxResolution!);
      }
    }
    if (widget.onCreated != null) {
      widget.onCreated!(_player);
    }
    _player.videoSize.addListener(_update);
    _player.showSubtitle.addListener(_update);
    if (kIsWeb) {
      _player.fullscreen.addListener(_fullscreenChange);
    }
  }

  @override
  void didUpdateWidget(MediaplayerView oldWidget) {
    if (widget.videoFit != oldWidget.videoFit ||
        widget.backgroundColor != oldWidget.backgroundColor) {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    if (!_foreignPlayer) {
      _player.dispose();
    } else if (!_player.disposed) {
      _player.videoSize.removeListener(_update);
      _player.showSubtitle.removeListener(_update);
      if (kIsWeb) {
        _player.fullscreen.removeListener(_fullscreenChange);
        _clearOverlay();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      makeVideo(_player, widget.backgroundColor, widget.videoFit);
}
