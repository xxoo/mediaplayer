import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'player.web.dart';

Widget makeWidget(Mediaplayer player, Color backgroundColor, BoxFit videoFit) {
  if (player.videoSize.value == Size.zero) {
    return Container(
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
    );
  } else {
    final video = HtmlElementView(
      viewType: 'mediaplayer',
      creationParams: player.id,
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
    );
    player.setBackgroundColor(backgroundColor);
    if (videoFit == BoxFit.fitHeight || videoFit == BoxFit.fitWidth) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final aspectRatio =
              player.videoSize.value.width / player.videoSize.value.height;
          final boxAspectRatio = constraints.maxWidth / constraints.maxHeight;
          if (boxAspectRatio > aspectRatio) {
            player.setVideoFit(
              videoFit == BoxFit.fitHeight ? BoxFit.contain : BoxFit.cover,
            );
          } else {
            player.setVideoFit(
              videoFit == BoxFit.fitHeight ? BoxFit.cover : BoxFit.contain,
            );
          }
          return video;
        },
      );
    } else {
      player.setVideoFit(videoFit);
      return video;
    }
  }
}
