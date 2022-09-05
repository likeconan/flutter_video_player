import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream_method_channel.dart';

void main() {
  MethodChannelVideoPlayerOneplusdream platform = MethodChannelVideoPlayerOneplusdream();
  const MethodChannel channel = MethodChannel('video_player_oneplusdream');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
