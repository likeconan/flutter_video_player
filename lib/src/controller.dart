part of video_player_oneplusdream;

typedef VideoCreatedCallback = void Function(VideoPlayerController controller);
typedef OnPlayingCallback = void Function(PlayingEventDetail event);
typedef BackCallback = void Function();

class VideoPlayerController {
  VideoPlayerController._(
    this._videoPlayerState, {
    required this.videoId,
  }) {
    _connectStreams(videoId);
  }

  /// The videoId for this controller
  final int videoId;

  /// Initialize control of a [VideoPlayer] with [id].
  ///
  /// Mainly for internal use when instantiating a [VideoPlayerController] passed
  /// in [VideoPlayer.onCreated] callback.
  static Future<VideoPlayerController> init(
    int videoId,
    _VideoPlayerOnePlusDreamState _videoPlayerState,
  ) async {
    assert(videoId != null);
    await VideoPlayerOneplusdreamPlatform.instance.init(videoId);
    return VideoPlayerController._(
      _videoPlayerState,
      videoId: videoId,
    );
  }

  final _VideoPlayerOnePlusDreamState _videoPlayerState;

  void _connectStreams(int videoId) {
    if (_videoPlayerState.widget.onBack != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onBack(videoId: videoId)
          .listen((_) => _videoPlayerState.widget.onBack!());
    }
    if (_videoPlayerState.widget.onPlaying != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onPlaying(videoId: videoId)
          .listen((e) => _videoPlayerState.widget.onPlaying!(e.value));
    }
  }

  Future<void> play(PlayingItem item) {
    return VideoPlayerOneplusdreamPlatform.instance.play(videoId, item);
  }

  Future<void> toggleFullScreen(ToggleFullScreenParam param) {
    return VideoPlayerOneplusdreamPlatform.instance
        .toggleFullScreen(videoId, param);
  }

  Future<void> togglePause(bool isPause) {
    return VideoPlayerOneplusdreamPlatform.instance
        .togglePause(videoId, isPause);
  }

  /// Disposes of the platform resources
  void dispose() {
    VideoPlayerOneplusdreamPlatform.instance.dispose(videoId: videoId);
  }
}
