import 'dart:async';
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
  Future<void> init(int videoId) {
    final MethodChannel channel = ensureChannelInitialized(videoId);
    return channel.invokeMethod<void>('ready');
  }

  @override
  Future<void> toggleFullScreen(int videoId, ToggleFullScreenParam param) {
    final MethodChannel channel = ensureChannelInitialized(videoId);
    return channel.invokeMethod<void>(
        'toggleFullScreen', {"isFullScreen": param.isFullScreen});
  }

  @override
  Future<void> play(int videoId, PlayingItem item) {
    final MethodChannel channel = ensureChannelInitialized(videoId);
    return channel.invokeMethod<void>('play', item.toJson());
  }

  @override
  Future<void> togglePause(int videoId, bool isPause) {
    final MethodChannel channel = ensureChannelInitialized(videoId);
    print('called $isPause');
    return channel.invokeMethod<void>('togglePause', isPause);
  }

  @override
  Future<void> dispose({required int videoId}) {
    final MethodChannel channel = ensureChannelInitialized(videoId);
    return channel.invokeMethod<void>('release');
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int id) async {
    try {
      switch (call.method) {
        case ON_BACK_CLICKED:
          _videoEventStreamController.add(BackEvent(id));
          break;
        case ON_PLAYING:
          _videoEventStreamController.add(
              PlayingEvent(id, PlayingEventDetail.fromJson(call.arguments)));
          break;
        default:
          throw MissingPluginException();
      }
    } catch (e) {
      print("event error: $e");
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
  Stream<PlayingEvent> onPlaying({required int videoId}) {
    return _events(videoId).whereType<PlayingEvent>();
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
        onCreatePlatformView: (p) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: p.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: params,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              p.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(p.onPlatformViewCreated)
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
