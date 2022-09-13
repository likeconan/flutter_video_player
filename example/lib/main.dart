import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:video_player_oneplusdream/video_player.widget.dart';
import 'package:video_player_oneplusdream/video_player_event.model.dart';
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
  final _videoPlayerOneplusdreamPlugin = VideoPlayerOneplusdream();

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
                  child: VideoPlayer(),
                ),
                ElevatedButton(
                    onPressed: () {
                      _videoPlayerOneplusdreamPlugin
                          .toggleFullScreen(ToggleFullScreenParam());
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
