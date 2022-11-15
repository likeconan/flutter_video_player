import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'video_player_oneplusdream.dart';
import 'video_player_oneplusdream_platform_interface.dart';

/// An implementation of [VideoPlayerOneplusdreamPlatform] that uses method channels.
class MethodChannelVideoPlayerOneplusdream
    extends VideoPlayerOneplusdreamPlatform {
  /// The method channel used to interact with the native platform.
  // Keep a collection of id -> channel
  // Every method call passes the int id
  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

  /// Accesses the MethodChannel associated to the passed id.
  MethodChannel channel(int id) {
    final MethodChannel? channel = _channels[id];
    if (channel == null) {
      throw Exception("Unknown video player ID: $id");
    }
    return channel;
  }

  @visibleForTesting
  MethodChannel ensureChannelInitialized(int id) {
    print("channel init with id: $id");
    print("channel count: ${_channels.length}");
    MethodChannel? channel = _channels[id];
    if (channel == null) {
      channel = MethodChannel('oneplusdream/video_channel_$id');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, id));
      _channels[id] = channel;
    }
    return channel;
  }

  @override
  Future<void> init(int id) {
    final MethodChannel channel = ensureChannelInitialized(id);
    return channel.invokeMethod<void>('ready');
  }

  @override
  void dispose({required int videoId}) {
    // Noop!
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int id) async {
    switch (call.method) {
      case ON_BACK_CLICKED:
        _videoEventStreamController.add(BackEvent(id));
        break;
      default:
        throw MissingPluginException();
    }
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
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    Map<String, dynamic> params = const <String, dynamic>{},
  }) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const viewType = 'oneplusdream/video_player_android';
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
            creationParams: params,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'oneplusdream/video_player_ios',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }
}
