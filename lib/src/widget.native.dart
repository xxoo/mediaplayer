import 'package:flutter/widgets.dart';
import 'player.native.dart';

Widget makeVideo(Mediaplayer player, Color backgroundColor, BoxFit videoFit) =>
    Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child:
          player.videoSize.value == Size.zero
              ? null
              : FittedBox(
                fit: videoFit,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: player.videoSize.value.width,
                  height: player.videoSize.value.height,
                  child:
                      player.subId != null && player.showSubtitle.value
                          ? Stack(
                            textDirection: TextDirection.ltr,
                            fit: StackFit.passthrough,
                            children: [
                              Texture(textureId: player.id!),
                              Texture(textureId: player.subId!),
                            ],
                          )
                          : Texture(textureId: player.id!),
                ),
              ),
    );
