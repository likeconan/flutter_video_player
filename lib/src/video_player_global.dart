part of video_player_oneplusdream;

class VideoPlayerGlobal {
  /// private constructor
  static final VideoPlayerGlobal _instance = VideoPlayerGlobal._internal();

  // using a factory is important
  // because it promises to return _an_ object of this type
  // but it doesn't promise to make a new one.
  factory VideoPlayerGlobal() {
    return _instance;
  }

  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  VideoPlayerGlobal._internal() {
    // initialization logic
  }

  final _methodChannel = const MethodChannel('oneplusdream/global_channel');

  Future<void> cachePlayingItems(List<String> urls) async {
    await _methodChannel.invokeMethod("cache", urls);
  }

  Future<void> clearAllCache() async {
    await _methodChannel.invokeMethod("clearAllCache");
  }
}
