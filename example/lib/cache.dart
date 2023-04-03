import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

class CacheRoute extends StatelessWidget {
  VideoPlayerController? controller;
  CacheRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Route'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1 / 1,
            child: VideoPlayerOnePlusDream(
              [
                PlayingItem(
                  id: '1',
                  url:
                      "https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/2.mp4",
                  title: "Test 1",
                  aspectRatio: 16 / 9,
                  fitMode: FitMode.contain,
                ),
                PlayingItem(
                  id: '2',
                  url:
                      "https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/3.mp4",
                  title: "Test 2",
                  aspectRatio: 1 / 1,
                  fitMode: FitMode.cover,
                ),
              ],
              hideControls: true,
              enableMarquee: true,
              enablePreventScreenCapture: false,
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
              onVideoCreated: ((c) => controller = c),
            ),
          ),
        ],
      )),
    );
  }
}
