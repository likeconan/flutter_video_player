
import 'video_player_oneplusdream_platform_interface.dart';

class VideoPlayerOneplusdream {
  Future<String?> getPlatformVersion() {
    return VideoPlayerOneplusdreamPlatform.instance.getPlatformVersion();
  }
}
