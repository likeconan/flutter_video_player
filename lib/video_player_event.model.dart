class ToggleFullScreenParam {
  bool isFullScreen;
  bool shouldRotate;
  ToggleFullScreenParam({this.isFullScreen = true, this.shouldRotate = true});

  Map<String, dynamic> toJson() => {
        'isFullScreen': isFullScreen,
        'shouldRotate': shouldRotate,
      };
}
