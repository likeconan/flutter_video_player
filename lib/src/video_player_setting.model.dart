part of video_player_oneplusdream;

class PlayingItem {
  String url;
  String? title;
  double? position;
  PlayingItem(this.url, {this.title, this.position});

  factory PlayingItem.fromJson(json) {
    return PlayingItem(json['url'],
        title: json['title'], position: json['position']);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'position': position,
      };
}
