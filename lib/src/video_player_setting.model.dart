part of video_player_oneplusdream;

class PlayingItem {
  String url;
  String id;
  String? title;
  num? position;
  String? extra;
  num? aspectRatio;
  FitMode fitMode;

  PlayingItem({
    required this.id,
    required this.url,
    this.title,
    this.position,
    this.extra,
    this.aspectRatio,
    this.fitMode = FitMode.contain,
  });

  factory PlayingItem.fromJson(json) {
    return PlayingItem(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      position: json['position'],
      extra: json['extra'],
      aspectRatio: json['aspectRatio'],
      fitMode: parseFitMode(json['fitMode']),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'id': id,
        'title': title,
        'position': position,
        'extra': extra,
        'aspectRatio': aspectRatio,
        'fitMode': fitMode.index,
      };
}

enum FitMode { contain, cover }

final fitModes = [
  FitMode.contain,
  FitMode.cover,
];

FitMode parseFitMode(int v) {
  return v <= fitModes.length - 1 ? fitModes[v] : FitMode.contain;
}
