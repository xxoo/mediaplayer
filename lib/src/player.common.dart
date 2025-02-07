import 'package:flutter/widgets.dart';
import 'player.interface.dart';

/// This type is used by [MediaplayerInterface] to show the current playback state.
enum PlaybackState { playing, paused, closed }

/// This type is used by [MediaplayerInterface] to show the current buffer status.
class BufferRange {
  static const empty = BufferRange(0, 0);

  final int begin;
  final int end;
  const BufferRange(this.begin, this.end);
}

/// This type is used by [TrackInfo] to show the type of the track.
enum TrackType { audio, video, subtitle }

/// This type is used by [MediaInfo] to show information about a track.
/// Only [type] is guaranteed to be non-null. Other information may not be available and may vary by platform.
class TrackInfo {
  static TrackInfo fromMap(Map map) {
    final type = map['type'] as String;
    final format = map['format'] as String?;
    final language = map['language'] as String?;
    final title = map['title'] as String?;
    final bitRate = (map['bitRate'] as num?)?.toInt();
    final videoSize =
        map['width'] == null ||
                map['height'] == null ||
                map['width'] <= 0 ||
                map['height'] <= 0
            ? null
            : Size(map['width'], map['height']);
    final frameRate = map['frameRate'] as double?;
    final channels = (map['channels'] as num?)?.toInt();
    final sampleRate = (map['sampleRate'] as num?)?.toInt();
    final isHdr = map['isHdr'] as bool?;
    return TrackInfo(
      type == 'audio'
          ? TrackType.audio
          : type == 'video'
          ? TrackType.video
          : TrackType.subtitle,
      format: format == "" ? null : format,
      language: language == "" ? null : language,
      title: title == "" ? null : title,
      isHdr: isHdr,
      videoSize: videoSize,
      frameRate: frameRate != null && frameRate > 0 ? frameRate : null,
      bitRate: bitRate != null && bitRate > 0 ? bitRate : null,
      channels: channels != null && channels > 0 ? channels : null,
      sampleRate: sampleRate != null && sampleRate > 0 ? sampleRate : null,
    );
  }

  final TrackType type;
  final String? format;
  final String? language;
  final String? title;
  final int? bitRate;
  final Size? videoSize;
  final double? frameRate;
  final int? channels;
  final int? sampleRate;
  final bool? isHdr;
  const TrackInfo(
    this.type, {
    this.isHdr,
    this.format,
    this.language,
    this.title,
    this.videoSize,
    this.frameRate,
    this.bitRate,
    this.channels,
    this.sampleRate,
  });
}

/// This type is used by [MediaplayerInterface] to show current media info.
/// [duration] == 0 means the media is realtime stream.
/// [tracks] contains all the tracks of the media. The key is the track id. However, video tracks are only available on android/linux/hls.js.
class MediaInfo {
  final int duration;
  final Map<String, TrackInfo> tracks;
  final String source;
  const MediaInfo(this.duration, this.tracks, this.source);
}
