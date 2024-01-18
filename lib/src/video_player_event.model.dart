part of video_player_oneplusdream;

const TOGGLE_FULL_SCREEEN = "toggleFullScreen";
const ON_BACK_CLICKED = "onBack";
const ON_PLAYING = "onPlaying";
const ON_RATE_CHANGE = "onRateChange";
const ON_URL_REQUESTED = "onUrlRequested";
const RELEASE = "release";

class BackEvent extends VideoEvent<void> {
  BackEvent(int videoId) : super(videoId, null);
}

class PlayingEvent extends VideoEvent<PlayingEventDetail> {
  PlayingEvent(int videoId, PlayingEventDetail event) : super(videoId, event);
}

class RateChangeEvent extends VideoEvent<double> {
  RateChangeEvent(int videoId, double rate) : super(videoId, rate);
}

class UrlRequestedEvent extends VideoEvent<String> {
  UrlRequestedEvent(int videoId, String url) : super(videoId, url);
}

class PlayingEventDetail {
  PlayingItem item;
  PlayingStatus? status;
  num? currentPosition;
  num? duration;
  PlayingEventDetail(
    this.item,
    this.status,
    this.currentPosition,
    this.duration,
  );
  factory PlayingEventDetail.fromJson(json) {
    return PlayingEventDetail(
      PlayingItem.fromJson(json["item"]),
      parsePlayingStatus(json["status"]),
      json['currentPosition'],
      json['duration'],
    );
  }
  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'status': status?.name,
        'currentPosition': currentPosition,
        'duration': duration,
      };
}

enum PlayingStatus {
  start,
  pause,
  play,
  end,
  error,
  release,
}

final playingStatuses = [
  PlayingStatus.start,
  PlayingStatus.pause,
  PlayingStatus.play,
  PlayingStatus.end,
  PlayingStatus.error,
  PlayingStatus.release
];

PlayingStatus? parsePlayingStatus(int v) {
  return v <= playingStatuses.length - 1 ? playingStatuses[v] : null;
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
