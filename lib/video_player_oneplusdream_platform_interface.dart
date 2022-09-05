import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_player_oneplusdream_method_channel.dart';

abstract class VideoPlayerOneplusdreamPlatform extends PlatformInterface {
  /// Constructs a VideoPlayerOneplusdreamPlatform.
  VideoPlayerOneplusdreamPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoPlayerOneplusdreamPlatform _instance = MethodChannelVideoPlayerOneplusdream();

  /// The default instance of [VideoPlayerOneplusdreamPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoPlayerOneplusdream].
  static VideoPlayerOneplusdreamPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoPlayerOneplusdreamPlatform] when
  /// they register themselves.
  static set instance(VideoPlayerOneplusdreamPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
