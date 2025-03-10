// This example shows how to play a video from a URL with MediaplayerView widget.
// Which is a very basic way to use mediaplayer package.
// For more advanced usage, see main_advanced.dart.

import 'package:flutter/material.dart';
import 'package:mediaplayer/mediaplayer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _loading = true;

  @override
  Widget build(BuildContext context) => Stack(
        textDirection: TextDirection.ltr,
        alignment: Alignment.center,
        children: [
          MediaplayerView(
            initSource:
                'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
            initAutoPlay: true,
            initLooping: true,
            onCreated: (player) => player.loading.addListener(
                () => setState(() => _loading = player.loading.value)),
          ),
          if (_loading) const CircularProgressIndicator(),
        ],
      );
}
