class PlayingItem {
  String url;
  String? title;
  PlayingItem(this.url, {this.title});

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
      };
}
