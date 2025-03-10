// This example shows how to handle subtitle and audio tracks.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:set_state_async/set_state_async.dart';
import 'package:mediaplayer/mediaplayer.dart';

class TrackSelectorView extends StatefulWidget {
  const TrackSelectorView({super.key});

  @override
  State<TrackSelectorView> createState() => _TrackSelectorViewState();
}

// Please note that the SetStateAsync mixin is necessary cause setState() may be called during build process.
class _TrackSelectorViewState extends State<TrackSelectorView>
    with SetStateAsync {
  final _player = Mediaplayer(
    initSource:
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
    //initPosition: 300000,
    //initAutoPlay: true,
  );
  final _inputController = TextEditingController();

  @override
  initState() {
    super.initState();
    _player.showSubtitle.addListener(setStateAsync);
    _player.playbackState.addListener(setStateAsync);
    _player.position.addListener(setStateAsync);
    _player.overrideAudio.addListener(setStateAsync);
    _player.overrideSubtitle.addListener(setStateAsync);
    _player.videoSize.addListener(setStateAsync);
    _player.loading.addListener(setStateAsync);
    _player.mediaInfo.addListener(() {
      if (_player.mediaInfo.value != null) {
        _inputController.text = _player.mediaInfo.value!.source;
      }
      setStateAsync();
    });
    _player.error.addListener(() {
      if (_player.error.value != null) {
        debugPrint('Error: ${_player.error.value}');
      }
    });
    _player.bufferRange.addListener(() {
      if (_player.bufferRange.value != BufferRange.empty) {
        debugPrint(
            'position: ${_player.position.value} buffer start: ${_player.bufferRange.value.start} buffer end: ${_player.bufferRange.value.end}');
      }
    });
  }

  @override
  void dispose() {
    //We should dispose this player. cause it's created by user.
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    labelText: 'Open Media',
                    hintText: 'Please input a media URL',
                  ),
                  keyboardType: TextInputType.url,
                  onSubmitted: (value) {
                    if (value.isNotEmpty && Uri.tryParse(value) != null) {
                      _player.open(value);
                    }
                  },
                ),
                AspectRatio(
                  aspectRatio: _player.videoSize.value == Size.zero
                      ? 16 / 9
                      : _player.videoSize.value.width /
                          _player.videoSize.value.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MediaplayerView(initPlayer: _player),
                      if (_player.loading.value)
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
                Slider(
                  // min: 0,
                  max: (_player.mediaInfo.value?.duration ?? 0).toDouble(),
                  value: _player.position.value.toDouble(),
                  onChanged: (value) => _player.seekTo(value.toInt()),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Text(_formatDuration(
                      Duration(milliseconds: _player.position.value))),
                  const Spacer(),
                  Text(
                    _player.error.value ??
                        '${_player.videoSize.value.width.toInt()}x${_player.videoSize.value.height.toInt()}',
                  ),
                  const Spacer(),
                  Text(_formatDuration(
                    Duration(
                        milliseconds: _player.mediaInfo.value?.duration ?? 0),
                  )),
                ]),
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _player.play(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => _player.pause(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => _player.close(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    onPressed: () =>
                        _player.seekTo(_player.position.value - 5000),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fast_forward),
                    onPressed: () =>
                        _player.seekTo(_player.position.value + 5000),
                  ),
                  const Spacer(),
                  Icon(
                    _player.playbackState.value == PlaybackState.playing
                        ? Icons.play_arrow
                        : _player.playbackState.value == PlaybackState.paused
                            ? Icons.pause
                            : Icons.stop,
                    size: 16.0,
                    color: const Color(0x80000000),
                  ),
                  if (kIsWeb) ...[
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.picture_in_picture),
                      onPressed: () => _player.setPictureInPicture(true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () => _player.setFullscreen(true),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                DropdownMenu(
                  width: 150,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: "", label: "Auto detect"),
                    DropdownMenuEntry(value: "en", label: "English"),
                    DropdownMenuEntry(value: "it", label: "Italian"),
                  ],
                  label: const Text(
                    "Audio Language",
                    style: TextStyle(fontSize: 14),
                  ),
                  onSelected: (value) =>
                      _player.setPreferredAudioLanguage(value ?? ""),
                ),
                DropdownMenu(
                  width: 150,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: "", label: "Auto detect"),
                    DropdownMenuEntry(value: "en", label: "English"),
                    DropdownMenuEntry(value: "ja", label: "Japanese"),
                    DropdownMenuEntry(value: "es", label: "Spanish"),
                  ],
                  label: const Text(
                    "Subtitle Language",
                    style: TextStyle(fontSize: 14),
                  ),
                  onSelected: (value) =>
                      _player.setPreferredSubtitleLanguage(value ?? ""),
                ),
                DropdownMenu(
                  width: 150,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: "0", label: "Unlimited"),
                    DropdownMenuEntry(value: "4194304", label: "4Mbps"),
                    DropdownMenuEntry(value: "2097152", label: "2Mbps"),
                    DropdownMenuEntry(value: "1048576", label: "1Mbps"),
                  ],
                  label: const Text(
                    "Max bitrate",
                    style: TextStyle(fontSize: 14),
                  ),
                  onSelected: (value) =>
                      _player.setMaxBitRate(int.parse(value!)),
                ),
                DropdownMenu(
                  width: 150,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: "0x0", label: "Unlimited"),
                    DropdownMenuEntry(value: "1920x1080", label: "1080p"),
                    DropdownMenuEntry(value: "1280x720", label: "720p"),
                    DropdownMenuEntry(value: "640x360", label: "360p"),
                  ],
                  label: const Text(
                    "Max Resolution",
                    style: TextStyle(fontSize: 14),
                  ),
                  onSelected: (value) {
                    final parts = value!.split('x');
                    _player.setMaxResolution(
                        Size(double.parse(parts[0]), double.parse(parts[1])));
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _player.showSubtitle.value,
                onChanged: (value) => _player.setShowSubtitle(value ?? false),
              ),
              Text(
                'Subtitle Tracks: ${_player.mediaInfo.value?.subtitleTracks.length ?? 0}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          _buildListView(false),
          Text(
            'Audio Tracks: ${_player.mediaInfo.value?.audioTracks.length ?? 0}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          _buildListView(true),
        ],
      ));

  Widget _buildListView(bool isAudio) {
    final Set<String> ids;
    final ValueNotifier<String?> target;
    if (isAudio) {
      target = _player.overrideAudio;
      ids = _player.mediaInfo.value?.audioTracks.keys.toSet() ?? {};
    } else {
      target = _player.overrideSubtitle;
      ids = _player.mediaInfo.value?.subtitleTracks.keys.toSet() ?? {};
    }
    return SizedBox(
      height: isAudio ? 134 : 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16),
        itemCount: ids.length,
        itemBuilder: (context, index) {
          final id = ids.elementAt(index);
          final audioTrack =
              isAudio ? _player.mediaInfo.value!.audioTracks[id] : null;
          final subtitleTrack =
              isAudio ? null : _player.mediaInfo.value!.subtitleTracks[id];
          final selected = target.value == id;
          return InkWell(
            onTap: () => isAudio
                ? _player.setOverrideAudio(selected ? null : id)
                : _player.setOverrideSubtitle(selected ? null : id),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: selected ? Colors.blue : Colors.blueGrey,
              ),
              padding: const EdgeInsets.all(6),
              alignment: Alignment.center,
              child: Text(
                isAudio
                    ? '''${audioTrack!.title ?? 'unknown title'}
${audioTrack.language ?? 'unknown language'}
${audioTrack.channels != null ? '${audioTrack.channels} channels' : 'unknown channels'}
${audioTrack.bitRate != null ? _formatBitRate(audioTrack.bitRate!) : 'unknown bitrate'}
${audioTrack.sampleRate != null ? '${audioTrack.sampleRate!}Hz' : 'unknown sample rate'}
${audioTrack.format ?? 'unknown format'}'''
                    : '''${subtitleTrack!.title ?? 'unknown title'}
${subtitleTrack.language ?? 'unknown language'}
${subtitleTrack.format ?? 'unknown format'}''',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
      ),
    );
  }

  String _formatBitRate(int bitRate) {
    if (bitRate < 1024) {
      return '${bitRate}bps';
    } else if (bitRate < 1024 * 1024) {
      return '${(bitRate / 1024).round()}kbps';
    } else {
      return '${(bitRate / 1024 / 1024).round()}mbps';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours$minutes:$seconds';
  }
}
