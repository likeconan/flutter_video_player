// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'video_player_oneplusdream.dart';
import 'video_player_oneplusdream_platform_interface.dart';

/// A web implementation of the VideoPlayerOneplusdreamPlatform of the VideoPlayerOneplusdream plugin.
class VideoPlayerOneplusdreamWeb extends VideoPlayerOneplusdreamPlatform {
  /// Constructs a VideoPlayerOneplusdreamWeb
  VideoPlayerOneplusdreamWeb();

  static void registerWith(Registrar registrar) {
    VideoPlayerOneplusdreamPlatform.instance = VideoPlayerOneplusdreamWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future toggleFullScreen(int videoId, ToggleFullScreenParam param) async {
    // todo
  }

  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    Map<String, dynamic> params = const <String, dynamic>{},
  }) {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Text("Not implemented yet")),
    );
  }
}
