part of video_player_oneplusdream;

const TOGGLE_FULL_SCREEEN = "toggleFullScreen";
const ON_BACK_CLICKED = "onBack";
const ON_PLAYING = "onPlaying";
const RELEASE = "release";

class BackEvent extends VideoEvent<void> {
  BackEvent(int videoId) : super(videoId, null);
}

class PlayingEvent extends VideoEvent<PlayingEventDetail> {
  PlayingEvent(int videoId, PlayingEventDetail event) : super(videoId, event);
}

class PlayingEventDetail {
  PlayingItem item;
  PlayingStatus? status;
  PlayingEventDetail(this.item, this.status);
  factory PlayingEventDetail.fromJson(json) {
    return PlayingEventDetail(
        PlayingItem.fromJson(json["item"]), parsePlayingStatus(json["status"]));
  }
}

enum PlayingStatus {
  start,
  pause,
  play,
  end,
  error,
}

final playingStatuses = [
  PlayingStatus.start,
  PlayingStatus.pause,
  PlayingStatus.play,
  PlayingStatus.end,
  PlayingStatus.error,
];

PlayingStatus? parsePlayingStatus(int v) {
  return v <= 4 ? playingStatuses[v] : null;
}

class VideoEvent<T> {
  VideoEvent(this.videoId, this.value);
  final int videoId;
  final T value;
}

class ToggleFullScreenParam {
  bool isFullScreen;
  ToggleFullScreenParam({this.isFullScreen = true});

  Map<String, dynamic> toJson() => {
        'isFullScreen': isFullScreen,
      };
}
