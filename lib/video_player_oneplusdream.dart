import './src/video_player_event.model.dart';
import './src/video_player_oneplusdream_platform_interface.dart';

export 'src/video_player.widget.dart';
export 'src/video_player_event.constant.dart';
export 'src/video_player_event.model.dart';
export 'src/video_player_setting.model.dart';

class VideoPlayerOneplusdream {
  void setOnBackClicked(Future<dynamic> Function() handler) {
    VideoPlayerOneplusdreamPlatform.instance.setOnBackClicked(handler);
  }

  Future toggleFullScreen(ToggleFullScreenParam param) {
    return VideoPlayerOneplusdreamPlatform.instance.toggleFullScreen(param);
  }

  Future release() {
    return VideoPlayerOneplusdreamPlatform.instance.release();
  }
}
