part of video_player_oneplusdream;

const TOGGLE_FULL_SCREEEN = "toggleFullScreen";
const ON_BACK_CLICKED = "onBack";
const RELEASE = "release";

class BackEvent extends VideoEvent<void> {
  BackEvent(int videoId) : super(videoId, null);
}

class VideoEvent<T> {
  VideoEvent(this.videoId, this.value);
  final int videoId;
  final T value;
}

class ToggleFullScreenParam {
  bool isFullScreen;
  bool shouldRotate;
  ToggleFullScreenParam({this.isFullScreen = true, this.shouldRotate = true});

  Map<String, dynamic> toJson() => {
        'isFullScreen': isFullScreen,
        'shouldRotate': shouldRotate,
      };
}
