part of video_player_oneplusdream;

typedef OnPlayingCallback = void Function(PlayingEventDetail event);
typedef OnRateChangeCallback = void Function(double rate);
typedef OnUrlRequestedCallback = void Function(String url);

abstract class VideoPlayerController {
  Future<void> init(
    int videoId,
    VideoPlayerOnePlusDreamState videoPlayerState,
  );
  Future<void> play(PlayingItem item);
  Future<void> toggleFullScreen(ToggleFullScreenParam param);
  Future<void> togglePause(bool isPause);
  void dispose();
}
