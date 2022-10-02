import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_player_oneplusdream/video_player_setting.model.dart';

class VideoPlayer extends StatefulWidget {
  final bool autoPlay;
  final String? protectionText;
  final bool enablePreventScreenCapture;
  final String? marqueeText;
  final bool enableMarquee;
  final double? position;
  final List<PlayingItem> playingItems;
  VideoPlayer(
    this.playingItems, {
    this.autoPlay = true,
    this.protectionText,
    this.enablePreventScreenCapture = false,
    this.marqueeText,
    this.enableMarquee = false,
    this.position,
  });

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  void dispose() {
    super.dispose();
    try {} catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'video_player';
    // Pass parameters to the platform side.
    var creationParams = {
      "autoPlay": widget.autoPlay,
      "protectionText": widget.protectionText,
      "enablePreventScreenCapture": widget.enablePreventScreenCapture,
      "marqueeText": widget.marqueeText,
      "enableMarquee": widget.enableMarquee,
      "position": widget.position,
      "playingItems": widget.playingItems.map((e) => e.toJson()).toList()
    };
    if (TargetPlatform.android == defaultTargetPlatform) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (TargetPlatform.iOS == defaultTargetPlatform) {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      return Text("$defaultTargetPlatform platform not supported yet");
    }
  }
}
