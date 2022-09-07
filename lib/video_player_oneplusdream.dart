import 'video_player_oneplusdream_platform_interface.dart';

class VideoPlayerOneplusdream {
  Future toggleFullScreen() {
    return VideoPlayerOneplusdreamPlatform.instance.toggleFullScreen();
  }
}
