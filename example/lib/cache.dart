import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class CachePage extends StatelessWidget {
  VideoPlayerController? controller;
  CachePage({super.key});

  //Same demo videos
  String url1 = 'https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/2.mp4';
  String url2 = 'https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/3.mp4';
  String url3 = 'https://d305e11xqcgjdr.cloudfront.net/stories/4cf90380-e814-4f74-aac0-250a7b2cbaac/4.mp4';
  String url4 = 'https://d305e11xqcgjdr.cloudfront.net/stories/61cc00f1-6e16-4015-b92d-e34e55e28742/13.mp4';



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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Player with cache enabled. To test this feature, first plays "
                      "video, then leave this page, turn internet off and enter "
                      "page again",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              AspectRatio(
                aspectRatio: 4 / 3,
                child: VideoPlayerOnePlusDream([
                  PlayingItem(
                    id: '1',
                    url: url1,
                    aspectRatio: 16 / 9,
                    fitMode: FitMode.cover,
                  )
                ],
                  hideControls: true,
                  enableMarquee: false,
                  enablePreventScreenCapture: false,
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
              TextButton(
                child: Text("Play video1"),
                onPressed: () {
                  debugPrint('Playing video 1');
                  controller?.play( PlayingItem(
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
                  controller?.play( PlayingItem(
                    id: '2',
                    url: url2,
                    aspectRatio: 16 / 9,
                    fitMode: FitMode.contain,
                  ));
                },
              ),
              TextButton(
                onPressed: downloadfile,
                child: Text("Download video3 from Web"),
              ),
              TextButton(
                child: Text("Play video3"),
                onPressed: () async {
                  debugPrint('Playing video 3');
                  //Download video download from web and then played like local file
                  final appStorageDir = await getApplicationDocumentsDirectory();
                  String url3 = '${appStorageDir.path}/3.mp4';
                  bool fileExists = await checkFile(url3);
                  if (fileExists){
                    controller?.play( PlayingItem(
                      id: '2',
                      url: url3,
                      aspectRatio: 16 / 9,
                      fitMode: FitMode.contain,
                    ));
                  }
                },
              ),
              TextButton(
                child: Text("Pause video"),
                onPressed: () {
                  debugPrint('Pausing video');
                  controller?.togglePause(true);
                },
              ),
              TextButton(
                child: Text("Precache video"),
                onPressed: () {
                  debugPrint('Precaching video');
                  //controller?.preCache(videoSource);
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



  void downloadfile() async {
    // final tempDir = await getTemporaryDirectory();
    final tempDir = await getApplicationDocumentsDirectory();
    String filePath = '${tempDir.path}/3.mp4';
    final dio = Dio();
    print("Fetching a video from the web... please wait.");
    Response response = await dio.download(
        'https://d305e11xqcgjdr.cloudfront.net/stories/4cf90380-e814-4f74-aac0-250a7b2cbaac/4.mp4',
        filePath);
    if (response.statusCode == 200){
      print("Video fetched from web successfully: ${File(filePath).lengthSync()} bytes");
    } else{
      print("Couldn't fetch file from web");
    }
  }

//Check if a file exist on local storage
  Future<bool> checkFile(String filePath) async {
    //   final tempDir = await getTemporaryDirectory();
    final appStorageDir = await getApplicationDocumentsDirectory();
    // String filepath = "${appStorageDir.path}/$filePath";
    print(await File(filePath).exists());
    if (await File(filePath).exists()==true){
      //print('File exists: $filePath: ${File(filePath).lengthSync()} bytes');
      return true;
    } else{
      print("File $filePath doesn't Exists");
      return false;
    }
  }



}
