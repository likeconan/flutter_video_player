part of video_player_oneplusdream;

class VideoPlayerOnePlusDream extends StatefulWidget {
  /// if auto play at first
  /// default is true
  final bool autoPlay;

  /// if enabled when taking screen capture
  /// for ios the video will display a black cover with protectionText
  /// for android the video is visible to see but the captured video will be black
  /// default is false
  final bool enablePreventScreenCapture;

  /// the protection text that you want to show in black cover
  /// default is "In order to protect our digital content, please close record or share screen function"
  final String? protectionText;

  /// the content of marquee that displayed in video
  final String? marqueeText;

  /// to enable marquee when playing video
  /// default is false
  final bool enableMarquee;

  /// playing items must be set and not empty
  /// url is the video remote url
  /// title is the title of video
  /// position is the history
  /// extra is what you defined for further use
  /// aspectRatio is the ratio you want how video looks
  /// fitMode shows how the player fit in the view, it contains contain and cover
  final List<PlayingItem> playingItems;

  /// initial playing index, default value is 0
  final int initialPlayIndex;

  /// set poster image url when you don't want to play video at first
  final String? posterImage;

  /// if hide back back button at first
  /// default is false
  final bool hideBackButton;

  /// if hide controls always
  /// default is false
  final bool hideControls;

  /// used when you want to attach controller and invoke some function by controller
  final VideoCreatedCallback? onVideoCreated;

  /// back icon clicked when it's not in full screen mode
  final VoidCallback? onBack;

  /// onPlaying event
  final OnPlayingCallback? onPlaying;

  /// set the message when the last of the playing items is finished
  final String? lastPlayMessage;

  /// set buffer duration, minimum value should be 1
  final double? bufferDuration;

  const VideoPlayerOnePlusDream(
    this.playingItems, {
    this.autoPlay = true,
    this.protectionText,
    this.enablePreventScreenCapture = false,
    this.marqueeText,
    this.enableMarquee = false,
    this.posterImage,
    this.hideBackButton = false,
    this.initialPlayIndex = 0,
    this.onVideoCreated,
    this.onBack,
    this.onPlaying,
    this.lastPlayMessage,
    this.hideControls = false,
    this.bufferDuration,
    Key? key,
  }) : super(key: key);

  @override
  _VideoPlayerOnePlusDreamState createState() =>
      _VideoPlayerOnePlusDreamState();
}

var _nextVideoPlayerCreationId = 0;

class _VideoPlayerOnePlusDreamState extends State<VideoPlayerOnePlusDream> {
  final int _videoId = _nextVideoPlayerCreationId++;
  final Completer<VideoPlayerController> _controller =
      Completer<VideoPlayerController>();

  @override
  void dispose() {
    try {
      _disposeController();
    } catch (e) {
      print("release error $e");
    }
    super.dispose();
  }

  @override
  void deactivate() {
    try {
      _disposeController();
    } catch (e) {
      print("release error $e");
    }
    super.deactivate();
  }

  Future<void> _disposeController() async {
    final VideoPlayerController controller = await _controller.future;
    controller.dispose();
  }

  Future<void> onPlatformViewCreated(int id) async {
    final VideoPlayerController controller = await VideoPlayerController.init(
      id,
      this,
    );
    _controller.complete(controller);
    if (widget.onVideoCreated != null) {
      widget.onVideoCreated!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayerOneplusdreamPlatform.instance.buildView(
      _videoId,
      onPlatformViewCreated,
      params: {
        "autoPlay": widget.autoPlay,
        "protectionText": widget.protectionText,
        "enablePreventScreenCapture": widget.enablePreventScreenCapture,
        "marqueeText": widget.marqueeText,
        "enableMarquee": widget.enableMarquee,
        "playingItems": widget.playingItems.map((e) => e.toJson()).toList(),
        "initialPlayIndex": widget.initialPlayIndex,
        "posterImage": widget.posterImage,
        "hideBackButton": widget.hideBackButton,
        "lastPlayingMessage": widget.lastPlayMessage,
        "hideControls": widget.hideControls,
        "bufferDuration": widget.bufferDuration,
      },
    );
  }
}
