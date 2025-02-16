import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:mediaplayer/index.dart';
import 'sources.dart';

class VideoListView extends StatefulWidget {
  const VideoListView({super.key});

  @override
  State<VideoListView> createState() => _VideoListView();
}

// Please note that the SetStateAsync mixin is necessary cause setState() may be called during build process.
class _VideoListView extends State<VideoListView> with SetStateAsync {
  final _players = <Mediaplayer>[];

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < videoSources.length; i++) {
      final player = Mediaplayer(initLooping: true);
      // Listening to mediaInfo is optional in this case.
      // As loading always becomes false when mediaInfo is perpared.
      // player.mediaInfo.addListener(() => setState(() {}));
      player.loading.addListener(_update);
      player.videoSize.addListener(_update);
      _players.add(player);
    }
  }

  @override
  void dispose() {
    // We should dispose all the players. cause they are managed by the user.
    for (final player in _players) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InViewNotifierList(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 200),
        isInViewPortCondition:
            (double deltaTop, double deltaBottom, double viewPortDimension) =>
                deltaTop < (0.5 * viewPortDimension) &&
                deltaBottom > (0.5 * viewPortDimension),
        builder: (context, index) => InViewNotifierWidget(
          id: '$index',
          child: Container(
            margin: index == _players.length - 1
                ? null
                : const EdgeInsets.only(bottom: 16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MediaplayerView(initPlayer: _players[index]),
                  if (_players[index].mediaInfo.value != null &&
                      _players[index].videoSize.value == Size.zero)
                    const Text(
                      'Audio only',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  if (_players[index].loading.value)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
          builder: (context, isInView, child) {
            if (isInView) {
              // We should open the video only if it's not already opened and not loading.
              if (_players[index].mediaInfo.value == null &&
                  !_players[index].loading.value) {
                _players[index].open(videoSources[index]);
              }
              _players[index].play();
            } else {
              _players[index].pause();
            }
            return child!;
          },
        ),
        itemCount: _players.length,
      );
}
