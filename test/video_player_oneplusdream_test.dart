import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream_platform_interface.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVideoPlayerOneplusdreamPlatform 
    with MockPlatformInterfaceMixin
    implements VideoPlayerOneplusdreamPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VideoPlayerOneplusdreamPlatform initialPlatform = VideoPlayerOneplusdreamPlatform.instance;

  test('$MethodChannelVideoPlayerOneplusdream is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVideoPlayerOneplusdream>());
  });

  test('getPlatformVersion', () async {
    VideoPlayerOneplusdream videoPlayerOneplusdreamPlugin = VideoPlayerOneplusdream();
    MockVideoPlayerOneplusdreamPlatform fakePlatform = MockVideoPlayerOneplusdreamPlatform();
    VideoPlayerOneplusdreamPlatform.instance = fakePlatform;
  
    expect(await videoPlayerOneplusdreamPlugin.getPlatformVersion(), '42');
  });
}
