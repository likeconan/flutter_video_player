import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';
import 'package:video_player_oneplusdream_example/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    cache();
  }

  cache() async {
    await VideoPlayerGlobal().cachePlayingItems(
      [
        "https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/2.mp4'",
        "https://d305e11xqcgjdr.cloudfront.net/stories/4cf90380-e814-4f74-aac0-250a7b2cbaac/4.mp4",
        "https://d305e11xqcgjdr.cloudfront.net/stories/61cc00f1-6e16-4015-b92d-e34e55e28742/13.mp4",
      ],
      concurrent: false,
    );
    VideoPlayerGlobal().cancelCache([
      "https://d305e11xqcgjdr.cloudfront.net/stories/4cf90380-e814-4f74-aac0-250a7b2cbaac/4.mp4",
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeRoute(),
    );
  }
}
