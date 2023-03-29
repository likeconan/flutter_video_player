part of video_player_oneplusdream;

class PlayingItem {
  String url;
  String id;
  String? title;
  num? position;
  String? extra;
  PlayingItem({
    required this.id,
    required this.url,
    this.title,
    this.position,
    this.extra,
  });

  factory PlayingItem.fromJson(json) {
    return PlayingItem(
        id: json['id'],
        url: json['url'],
        title: json['title'],
        position: json['position']);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'id': id,
        'title': title,
        'position': position,
        'extra': extra
      };
}
