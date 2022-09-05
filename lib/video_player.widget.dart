import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class VideoPlayer extends StatefulWidget {
  VideoPlayer();

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
    var param = {};
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
            creationParams: param,
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
        creationParams: param,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      return Text("$defaultTargetPlatform platform not supported yet");
    }
  }
}
