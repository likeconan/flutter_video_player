import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

import 'first.dart';

class HomeRoute extends StatelessWidget {
  HomeRoute({super.key});
  VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: VideoPlayerOnePlusDream(
                  [
                    PlayingItem(
                        "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                        title: "Rabbit"),
                    PlayingItem(
                        "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
                        title: "BigBop"),
                  ],
                  enableMarquee: true,
                  enablePreventScreenCapture: true,
                  marqueeText: "What",
                  autoPlay: false,
                  onBack: () => print("onBack2"),
                  onPlaying: (event) {
                    print("onPlaying happened");
                    print(event);
                  },
                  onVideoCreated: ((c) => controller = c),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    controller?.togglePause(true);
                    print("pause");
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FirstRoute()),
                    );
                    print("back");
                    await controller?.togglePause(false);
                  },
                  child: Text("go to new page")),
              ElevatedButton(
                  onPressed: () {
                    controller?.toggleFullScreen(
                        ToggleFullScreenParam(isFullScreen: true));
                  },
                  child: Text("open full screen")),
              ElevatedButton(
                  onPressed: () {
                    controller?.play(PlayingItem(
                        "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
                        title: "Hello world"));
                  },
                  child: Text("play another item"))
            ],
          ),
        ),
      ),
    );
  }
}
