import 'dart:ui' as ui;
import 'dart:html' as html;

import '../video_player_oneplusdream.dart';
import '../video_player_oneplusdream_platform_interface.dart';

class WebVideoPlayerController implements VideoPlayerController {
  /// The videoId for this controller
  int _videoId = -1;
  VideoPlayerOnePlusDreamState? _videoPlayerState;

  @override
  Future<void> init(
    int videoId,
    VideoPlayerOnePlusDreamState videoPlayerState,
  ) async {
    _videoId = videoId;
    _videoPlayerState = videoPlayerState;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('video_$_videoId', (int id) {
      final html.Element htmlElement = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..children = [
          html.VideoElement()
            ..id = 'video_$_videoId'
            ..style.height = "100%"
            ..style.width = "100%"
            ..className = "video-js vjs-default-skin",
        ];
      return htmlElement;
    });
    await VideoPlayerOneplusdreamPlatform.instance.init(_videoId);
    _connectStreams(_videoId);
  }

  void _connectStreams(int videoId) {
    if (_videoPlayerState?.widget.onBack != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onBack(videoId: videoId)
          .listen((_) => _videoPlayerState?.widget.onBack!());
    }
    if (_videoPlayerState?.widget.onPlaying != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onPlaying(videoId: videoId)
          .listen((e) => _videoPlayerState?.widget.onPlaying!(e.value));
    }
    if (_videoPlayerState?.widget.onRateChange != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onRateChange(videoId: videoId)
          .listen((e) => _videoPlayerState?.widget.onRateChange!(e.value));
    }
    if (_videoPlayerState?.widget.onUrlRequested != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onUrlRequested(videoId: videoId)
          .listen((e) => _videoPlayerState?.widget.onUrlRequested!(e.value));
    }
  }

  @override
  Future<void> play(PlayingItem item) {
    return VideoPlayerOneplusdreamPlatform.instance.play(_videoId, item);
  }

  @override
  Future<void> toggleFullScreen(ToggleFullScreenParam param) {
    return VideoPlayerOneplusdreamPlatform.instance
        .toggleFullScreen(_videoId, param);
  }

  @override
  Future<void> togglePause(bool isPause) {
    return VideoPlayerOneplusdreamPlatform.instance
        .togglePause(_videoId, isPause);
  }

  @override

  /// Disposes of the platform resources
  void dispose() {
    VideoPlayerOneplusdreamPlatform.instance.dispose(videoId: _videoId);
  }
}

VideoPlayerController createVideoController() => WebVideoPlayerController();
