import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_player_event.constant.dart';
import 'video_player_event.model.dart';
import 'video_player_oneplusdream_platform_interface.dart';

/// An implementation of [VideoPlayerOneplusdreamPlatform] that uses method channels.
class MethodChannelVideoPlayerOneplusdream
    extends VideoPlayerOneplusdreamPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_player_oneplusdream');

  MethodChannelVideoPlayerOneplusdream() {
    methodChannel.setMethodCallHandler((call) async {
      print("call ${call.method}");
      switch (call.method) {
        case ON_BACK_CLICKED:
          for (var c in onBackClickedFuncList) {
            await c();
          }
          break;
        default:
      }
    });
  }

  @override
  Future toggleFullScreen(ToggleFullScreenParam param) async {
    await methodChannel.invokeMethod(TOGGLE_FULL_SCREEEN, param.toJson());
  }

  @override
  Future release() async {
    await methodChannel.invokeMethod(RELEASE);
  }

  @override
  void onBackClicked() async {}
}
