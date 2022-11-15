import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  late final VideoPlayerController controller1;
  late final VideoPlayerController controller2;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SafeArea(
            child: Column(
              children: [
                Text("hello world"),
                SizedBox(
                  height: 200,
                  child: VideoPlayerOnePlusDream([
                    PlayingItem(
                        "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                        title: "Rabbit"),
                    PlayingItem(
                        "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
                        title: "BigBop"),
                  ],
                      enableMarquee: true,
                      enablePreventScreenCapture: true,
                      marqueeText: "Hello",
                      autoPlay: false,
                      onBack: () => print("onBack1"),
                      onVideoCreated: ((controller) =>
                          controller1 = controller)),
                ),
                Text("Second"),
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
                    onVideoCreated: ((controller) => controller2 = controller),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      // _videoPlayerOneplusdreamPlugin
                      //     .toggleFullScreen(ToggleFullScreenParam());
                    },
                    child: Text("open full screen"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
