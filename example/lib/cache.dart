import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

import 'video.controller.dart';

class CacheRoute extends StatelessWidget {
  CacheRoute({super.key});

  //Same demo videos
  String url1 =
      'https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/2.mp4';
  String url2 =
      'https://d305e11xqcgjdr.cloudfront.net/stories/61cc00f1-6e16-4015-b92d-e34e55e28742/13.mp4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Player with cache enabled. To test this feature, first plays "
              "video, then leave this page, turn internet off and enter "
              "page again",
              style: TextStyle(fontSize: 16),
            ),
          ),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: VideoPlayerOnePlusDream(
              [
                PlayingItem(
                  id: '1',
                  url: url1,
                  aspectRatio: 16 / 9,
                  fitMode: FitMode.contain,
                ),
                PlayingItem(
                  id: '2',
                  url: url2,
                  title: "Test 2",
                  aspectRatio: 16 / 9,
                  fitMode: FitMode.cover,
                ),
              ],
              hideBackButton: true,
              hideControls: true,
              bufferDuration: 1,
              marqueeText: "Hello",
              autoPlay: false,
              onBack: () {
                print("onBack called");
                Navigator.pop(context);
              },
              onPlaying: (event) {
                print(
                    "onPlaying event happened $event, ${event.status}, po ${event.currentPosition}");
              },
              onVideoCreated: ((c) => cacheController = c),
            ),
          ),
          TextButton(
            child: Text("Play video1"),
            onPressed: () {
              debugPrint('Playing video 1');
              cacheController?.play(PlayingItem(
                id: '1',
                url: url1,
                aspectRatio: 16 / 9,
                fitMode: FitMode.contain,
              ));
            },
          ),
          TextButton(
            child: Text("Play video2"),
            onPressed: () {
              debugPrint('Playing video 2');
              cacheController?.play(PlayingItem(
                id: '2',
                url: url2,
                aspectRatio: 16 / 9,
                fitMode: FitMode.cover,
              ));
            },
          ),
          TextButton(
            child: Text("Play video"),
            onPressed: () {
              cacheController?.togglePause(false);
            },
          ),
          TextButton(
            child: Text("Pause video"),
            onPressed: () {
              cacheController?.togglePause(true);
            },
          ),
          TextButton(
            child: Text("Precache video"),
            onPressed: () {
              debugPrint('Precaching video');
              //controller!.preCache(videoSource);
            },
          ),
          TextButton(
            child: Text("Clear cache"),
            onPressed: () {
              //controller?.clearCache();
            },
          ),
        ],
      )),
    );
  }
}
