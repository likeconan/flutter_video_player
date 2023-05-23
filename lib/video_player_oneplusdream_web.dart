// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:rxdart/rxdart.dart';

import 'video_player_oneplusdream.dart';
import 'video_player_oneplusdream_platform_interface.dart';
import 'dart:js' as js;

/// A web implementation of the VideoPlayerOneplusdreamPlatform of the VideoPlayerOneplusdream plugin.
class VideoPlayerOneplusdreamWeb extends VideoPlayerOneplusdreamPlatform {
  String elementId = "";
  dynamic player;
  final List<String> scripts = [
    "packages/video_player_oneplusdream/lib/assets/videojs_playlist.min.js",
    "packages/video_player_oneplusdream/lib/assets/controller.js"
  ];

  /// Constructs a VideoPlayerOneplusdreamWeb
  VideoPlayerOneplusdreamWeb() {
    elementId = generateRandomString(7);
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(elementId, (int id) {
      final html.Element htmlElement = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..children = [
          html.VideoElement()
            ..id = elementId
            ..style.height = "100%"
            ..style.width = "100%"
            ..className = "video-js vjs-default-skin",
        ];
      return htmlElement;
    });
  }
  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  Future<void> importJSFile(String library) async {
    final head = html.querySelector('head');
    if (library.endsWith('.js')) {
      await _createScriptTag(library, head: head);
    } else if (library.endsWith('.css')) {
      await _createCssLinkTag(library, head: head);
    }
  }

  Future<void> _createScriptTag(String library, {html.Element? head}) async {
    late html.ScriptElement script;
    if (library.startsWith('http')) {
      script = html.ScriptElement()
        ..type = "text/javascript"
        ..charset = "utf-8"
        ..async = true
        ..src = library;
    } else {
      var val = await rootBundle.loadString(library);
      script = html.ScriptElement()
        ..type = "text/javascript"
        ..charset = "utf-8"
        ..async = true
        ..text = val;
    }
    head?.children.add(script);
  }

  Future<void> _createCssLinkTag(String library, {html.Element? head}) async {
    if (library.startsWith('http')) {
      var link = html.LinkElement()
        ..rel = "stylesheet"
        ..href = library;
      head?.children.add(link);
    } else {
      var val = await rootBundle.loadString(library);
      final html.StyleElement ele = html.StyleElement()..text = val;
      head?.children.add(ele);
    }
  }

  @override
  Future<void> toggleFullScreen(
      int videoId, ToggleFullScreenParam param) async {
    JsFunction func = player['requestFullscreen'];
    func.apply([], thisArg: player);
  }

  @override
  Future<void> play(int videoId, PlayingItem item) async {
    JsFunction func = player['src'];
    func.apply([
      js.JsObject.jsify({"src": item.url}),
    ], thisArg: player);
    if ((item.position ?? 0) > 0) {
      JsFunction setCurrentTime = player['currentTime'];
      setCurrentTime.apply([item.position], thisArg: player);
    }
    JsFunction setTitle = player['updateTitleFunc'];
    setTitle.apply([item.title], thisArg: player);
  }

  @override
  Future<void> togglePause(int videoId, bool isPause) async {
    if (isPause) {
      JsFunction func = player['pause'];
      func.apply([], thisArg: player);
    } else {
      JsFunction func = player['play'];
      func.apply([], thisArg: player);
    }
  }

  @override
  Future<void> dispose({required int videoId}) async {
    js.context['oneplusdreamOnPlayerListen_$videoId'] = null;
  }

  final StreamController<VideoEvent<Object?>> _videoEventStreamController =
      StreamController<VideoEvent<Object?>>.broadcast();

  Stream<VideoEvent<Object?>> _events(int videoId) =>
      _videoEventStreamController.stream
          .where((VideoEvent<Object?> event) => event.videoId == videoId);

  @override
  Stream<BackEvent> onBack({required int videoId}) {
    return _events(videoId).whereType<BackEvent>();
  }

  @override
  Stream<PlayingEvent> onPlaying({required int videoId}) {
    return _events(videoId).whereType<PlayingEvent>();
  }

  @override
  Future<void> init(int videoId) async {
    js.context['oneplusdreamOnPlayerListen_$videoId'] = (method, arguments) {
      try {
        switch (method) {
          case ON_BACK_CLICKED:
            _videoEventStreamController.add(BackEvent(videoId));
            break;
          case ON_PLAYING:
            _videoEventStreamController.add(
                PlayingEvent(videoId, PlayingEventDetail.fromJson(arguments)));
            break;
          default:
            throw MissingPluginException();
        }
      } catch (e) {
        print("event error: $e");
      }
    };
  }

  void initPlayer(int videoId, Map<String, dynamic> params) async {
    for (var script in scripts) {
      await importJSFile(script);
    }
    player = js.context.callMethod('videojs', [
      html.document.getElementById(elementId),
      js.JsObject.jsify({
        "fill": true,
        "responsive": true,
        "controls": true,
        "autoplay": true,
        "preload": true,
        "poster": params["posterImage"],
        "playbackRates": [0.5, 1, 1.25, 1.5, 2],
      })
    ]);

    js.context.callMethod('oneplusdreamInitialPlayer',
        [player, js.JsObject.jsify(params), videoId]);
  }

  static void registerWith(Registrar registrar) {
    VideoPlayerOneplusdreamPlatform.instance = VideoPlayerOneplusdreamWeb();
  }

  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    Map<String, dynamic> params = const <String, dynamic>{},
  }) {
    return HtmlElementView(
      viewType: elementId,
      onPlatformViewCreated: (id) {
        onPlatformViewCreated(id);
        initPlayer(creationId, params);
      },
    );
  }
}
