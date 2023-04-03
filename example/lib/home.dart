import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';
import 'package:video_player_oneplusdream_example/cache.dart';

import 'first.dart';

class HomeRoute extends StatelessWidget {
  HomeRoute({super.key});
  VideoPlayerController? controller;
  List<PlayingItem> items = [
    PlayingItem(
      id: '1',
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      title: "Rabbit",
      position: 20.0,
    ),
    PlayingItem(
      id: '2',
      url: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
      title: "BigBop",
      position: 54.0,
    ),
    PlayingItem(
      id: '3',
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      title: "Rabbit 3",
    ),
  ];

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
                  items,
                  enableMarquee: true,
                  enablePreventScreenCapture: true,
                  marqueeText: "Marquee",
                  autoPlay: true,
                  onPlaying: (event) {
                    print(
                        "status ${event.status} position: ${event.currentPosition}");
                    print("onPlaying ${event.item.url}");
                  },
                  onVideoCreated: ((c) => controller = c),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    controller?.togglePause(true);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CacheRoute()),
                    );
                    await controller?.togglePause(false);
                  },
                  child: const Text("go to cache page")),
              ElevatedButton(
                  onPressed: () async {
                    controller?.togglePause(true);
                    print("pause to navigate into new page");
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FirstRoute()),
                    );
                    print("back and play again");
                    await controller?.togglePause(false);
                  },
                  child: const Text("go to new page")),
              ElevatedButton(
                  onPressed: () {
                    controller?.toggleFullScreen(
                        ToggleFullScreenParam(isFullScreen: true));
                  },
                  child: const Text("open full screen")),
              ElevatedButton(
                  onPressed: () {
                    controller?.play(items[1]);
                  },
                  child: const Text("play another item"))
            ],
          ),
        ),
      ),
    );
  }
}
