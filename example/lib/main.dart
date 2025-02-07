// This example shows how to use the MediaplayerView widget to play a video from a URL.
// Which is a very basic way to use mediaplayer package.
// For more advanced usage, see main_advanced.dart.

import 'package:flutter/material.dart';
import 'package:mediaplayer/index.dart';

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
            'https://stream.mux.com/v69RSHhFelSm4701snP22dYz2jICy4E4FUyk02rW4gxRM.m3u8',
        initAutoPlay: true,
        onCreated:
            (player) => player.loading.addListener(
              () => setState(() => _loading = player.loading.value),
            ),
      ),
      if (_loading) const CircularProgressIndicator(),
    ],
  );
}
