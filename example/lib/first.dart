import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

class FirstRoute extends StatelessWidget {
  VideoPlayerController? controller;
  FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 200,
            child: VideoPlayerOnePlusDream(
              [
                PlayingItem("https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    title: "Rabbit"),
                PlayingItem(
                    "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
                    title: "BigBop"),
              ],
              enableMarquee: true,
              enablePreventScreenCapture: true,
              marqueeText: "Hello",
              autoPlay: false,
              onBack: () {
                print("onBack called");
                Navigator.pop(context);
              },
              onPlaying: (event) {
                print("onPlaying event happened $event");
              },
              onVideoCreated: ((c) => controller = c),
            ),
          ),
        ],
      )),
    );
  }
}
