# Video Player Plugin For Flutter With Useful Functions

A Flutter plugin for iOS, Android and Web for playing back video on a Widget surface.

|             | Android | iOS   | Web   |
|-------------|---------|-------|-------|
| **Support** | SDK 24+ | 13.0+ | Any\* |

![The example app running in Android](https://github.com/likeconan/flutter_video_player/blob/master/demo_preview.gif)

## Installation

First, add `video_player_oneplusdream` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### iOS

If you need to access videos using `http` (rather than `https`) URLs, you will need to add
the appropriate `NSAppTransportSecurity` permissions to your app's _Info.plist_ file, located
in `<project root>/ios/Runner/Info.plist`. See
[Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity)
to determine the right combination of entries for your use case and supported iOS versions.

### Android

If you are using network-based videos, ensure that the following permission is present in your
Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Web

> Please check [video.js](https://videojs.com) documentation for details


## Supported Formats

- On iOS, the backing player is [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer).
  The supported formats vary depending on the version of iOS, [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset) class
  has [audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc) that you can query for supported av formats.
- On Android, the backing player is [ExoPlayer](https://google.github.io/ExoPlayer/),
  please refer [here](https://google.github.io/ExoPlayer/supported-formats.html) for list of supported formats.
- On Web, the backing player is video.js

## Example

<?code-excerpt "basic.dart (basic-example)"?>
```dart
import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';

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
                  marqueeText: "Hello",
                  autoPlay: true,
                  onBack: () => print("onBack2"),
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
                      MaterialPageRoute(builder: (_) => FirstRoute()),
                    );
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
                    controller?.play(items[1]);
                  },
                  child: Text("play another item"))
            ],
          ),
        ),
      ),
    );
  }
}
```
Furthermore, see the example app for playing around.


## Usage and APIs
Most of useful functions are integrated inside native, so it's easy for you to use without implementing them in flutter code. Please see how to use and the API documentation, if you have any requests you could [create an issue](https://github.com/likeconan/flutter_video_player/issues)

### List functions

|                                         | Android            | iOS                 | Web                |
|-----------------------------------------|--------------------|---------------------|--------------------|
| **Backing Player**                      | ExoPlayer          | AVPlayer            | video.js           |
| **Horizontal Swipe To Seek**            | :heavy_check_mark: | :heavy_check_mark:  |                    |
| **Left Vertical Swipe To Brightness**   | :heavy_check_mark: | :heavy_check_mark:  |                    |
| **Right Vertical Swipe To Volume**      | :heavy_check_mark: | :heavy_check_mark:  |                    |
| **Play Rate Change**                    | :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |
| **Picture in Picture**                  |                    | :heavy_check_mark:  | :heavy_check_mark: |
| **FullScreen**                          | :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |
| **Poster Image**                        | :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |
| **Prevent Screen Capture**              | :heavy_check_mark: | :heavy_check_mark:  |                    |
| **Marquee Text**                        | :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |

### APIs

#### VideoPlayerOnePlusDream Widget Parameters

**PlayingItem** required

It's required when you use with VideoPlayerOnePlusDream Widget, the PlayingItem model has below attributes

|              | Type | Required | Comment   |
|--------------|---------|-------|-|
| **id**       | String  | YES | id is used for identify which item you are playing, in web we use url to identify which item is playing |
| **url**      | String | YES | the playing url which should be http or https |
| **title**    | String |  | title which will show in player |
| **position** | num |  | the initial playing position (seconds) for this item |
| **extra**    | String |  | any string you want to set for this item |

**autoPlay** optional (default = true)

If let the player auto play when the playing item is ready or not. Default value is true, if set to false, player will show a poster image.

**protectionTex** optional (default = 'In order to protect our digital content, please close record or share screen function')

Only used for iOS, when you enable prevent screen capture, if there is screen capture, the playback is pause and it will show a black background with the protection text.

**enablePreventScreenCapture** optional (default = false)

Only support in iOS and Android, the screen capture will take black playback.

**enableMarquee** optional (default = false)

When it's enabled, there will be a random marquee show in the playback.

**marqueeText** optional

You should set enableMarquee to true and the set your marqueeText to make it work.

**posterImage** optional

When player is set with auto play, then it will show poster image at first, user can click on the image to start play. When there is no value, it will use default asset.

**hideBackButton** optional (default = false)

Only support in iOS and Android,  it's always hide in web. When the back icon is clicked, it will trigger onBack event.

**initialPlayIndex** optional (default = 0)

The initial play item when the player is ready.

**onVideoCreated** optional (default = null)

When the player is created, the function is called with *VideoPlayerController* parameter.

**onBack** optional (default = null)

When the hide back button is clicked in not full screen mode, the onBack function is called.

**onPlaying** optional (default = null)

When player different playing status changes, the function is called with *PlayingEventDetail* parameter, like start, pause, play, end, error, release.

#### VideoPlayerController

A controller that you can handle player event in flutter side.

**play**

Pass PlayingItem model to play another item, it can be one of the initial PlayingItems, or any other one.

**togglePause**

Pass true or false to pause or play the player

**toggleFullScreen**

Pass true or false to enter or exit full screen mode

#### PlayingEventDetail

|                        | Type         | Required | Comment   |
|------------------------|--------------|----------|-|
| **item**               | PlayingItem  | YES      | current playing item |
| **status**             | Enum         |          | playing status for start, pause, play, end, error, release |
| **currentPosition**    | num          |          | current position (second) when the status is changed |

