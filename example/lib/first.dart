import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

class FirstRoute extends StatelessWidget {
  VideoPlayerController controller = createVideoController();
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
                PlayingItem(
                  id: '1',
                  url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                  title: "Rabbit",
                  position: 30,
                ),
                PlayingItem(
                  id: '2',
                  url:
                      "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
                  title: "BigBop",
                  position: 90,
                ),
              ],
              controller: controller,
              initialPlayIndex: 1,
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
            ),
          ),
        ],
      )),
    );
  }
}
