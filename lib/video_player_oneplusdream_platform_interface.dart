import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_player_oneplusdream.dart';
import 'video_player_oneplusdream_method_channel.dart';

abstract class VideoPlayerOneplusdreamPlatform extends PlatformInterface {
  /// Constructs a VideoPlayerOneplusdreamPlatform.
  VideoPlayerOneplusdreamPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoPlayerOneplusdreamPlatform _instance =
      MethodChannelVideoPlayerOneplusdream();

  /// The default instance of [VideoPlayerOneplusdreamPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoPlayerOneplusdream].
  static VideoPlayerOneplusdreamPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoPlayerOneplusdreamPlatform] when
  /// they register themselves.
  static set instance(VideoPlayerOneplusdreamPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// This method is called when the plugin is first initialized.
  Future<void> init(int videoId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future toggleFullScreen(int videoId, ToggleFullScreenParam param) {
    throw UnimplementedError('toggleFullScreen() has not been implemented.');
  }

  Stream<BackEvent> onBack({required int videoId}) {
    throw UnimplementedError('onBack() has not been implemented.');
  }

  Stream<PlayingEvent> onPlaying({required int videoId}) {
    throw UnimplementedError('onPlaying() has not been implemented.');
  }

  Future play(int videoId, PlayingItem item) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future togglePause(int videoId, bool isPause) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  Future dispose({required int videoId}) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    Map<String, dynamic> params = const <String, dynamic>{},
  }) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  /// Dispose of whatever resources the `videoId` is holding on to.
}
