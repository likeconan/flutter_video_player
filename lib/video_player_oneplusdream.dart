import 'video_player_event.model.dart';
import 'video_player_oneplusdream_platform_interface.dart';

class VideoPlayerOneplusdream {
  Future toggleFullScreen(ToggleFullScreenParam param) {
    return VideoPlayerOneplusdreamPlatform.instance.toggleFullScreen(param);
  }
}
