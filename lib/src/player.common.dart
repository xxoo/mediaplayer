import 'player.interface.dart';

/// This type is used by [MediaplayerInterface.playbackState].
enum PlaybackState { playing, paused, closed }

/// This type is used by [MediaplayerInterface.bufferRange].
class BufferRange {
  static const empty = BufferRange(0, 0);

  final int start;
  final int end;
  const BufferRange(this.start, this.end);
}

/// This type is used by [MediaInfo.subtitleTracks].
class SubtitleInfo {
  static SubtitleInfo fromMap(Map map) {
    final format = map['format'] as String?;
    final language = map['language'] as String?;
    final title = map['title'] as String?;
    return SubtitleInfo(
      format: format == "" ? null : format,
      language: language == "" ? null : language,
      title: title == "" ? null : title,
    );
  }

  final String? format;
  final String? language;
  final String? title;
  const SubtitleInfo({this.format, this.language, this.title});
}

/// This type is used by [MediaInfo.audioTracks].
class AudioInfo {
  static AudioInfo fromMap(Map map) {
    final format = map['format'] as String?;
    final language = map['language'] as String?;
    final title = map['title'] as String?;
    final bitRate = (map['bitRate'] as num?)?.toInt();
    final channels = (map['channels'] as num?)?.toInt();
    final sampleRate = (map['sampleRate'] as num?)?.toInt();
    return AudioInfo(
      format: format == "" ? null : format,
      language: language == "" ? null : language,
      title: title == "" ? null : title,
      bitRate: bitRate != null && bitRate > 0 ? bitRate : null,
      channels: channels != null && channels > 0 ? channels : null,
      sampleRate: sampleRate != null && sampleRate > 0 ? sampleRate : null,
    );
  }

  final String? format;
  final String? language;
  final String? title;
  final int? bitRate;
  final int? channels;
  final int? sampleRate;
  const AudioInfo({
    this.format,
    this.language,
    this.title,
    this.bitRate,
    this.channels,
    this.sampleRate,
  });
}

/// This type is used by [MediaplayerInterface.mediaInfo].
/// [duration] == 0 means the media is realtime stream.
/// [audioTracks] and [subtitleTracks] are maps with track id as key.
class MediaInfo {
  final int duration;
  final Map<String, AudioInfo> audioTracks;
  final Map<String, SubtitleInfo> subtitleTracks;
  final String source;
  const MediaInfo(
    this.duration,
    this.audioTracks,
    this.subtitleTracks,
    this.source,
  );
}
