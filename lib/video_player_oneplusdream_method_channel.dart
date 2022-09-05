import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_player_oneplusdream_platform_interface.dart';

/// An implementation of [VideoPlayerOneplusdreamPlatform] that uses method channels.
class MethodChannelVideoPlayerOneplusdream extends VideoPlayerOneplusdreamPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_player_oneplusdream');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
