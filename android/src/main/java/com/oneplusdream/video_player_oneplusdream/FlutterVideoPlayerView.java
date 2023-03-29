package com.oneplusdream.video_player_oneplusdream;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.Map;

class FlutterVideoPlayerView extends PlatformViewFactory implements MethodChannel.MethodCallHandler {

    private PlayerViewContainer _playerViewContainer;
    private Activity activity;
    private FlutterPlugin.FlutterPluginBinding _flutterPluginBinding;

    FlutterVideoPlayerView(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        super(StandardMessageCodec.INSTANCE);
        _flutterPluginBinding = flutterPluginBinding;
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        MethodChannel channel = new MethodChannel(_flutterPluginBinding.getBinaryMessenger(), "oneplusdream/video_channel_" + id);
        channel.setMethodCallHandler(this);
        _playerViewContainer = new PlayerViewContainer(context, creationParams, activity, channel);
        return _playerViewContainer;
    }

    public void setActivity(Activity _act) {
        activity = _act;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            if (call.method.equals("toggleFullScreen")) {
                _playerViewContainer.toggleFullScreen();
                result.success(null);
            } else if (call.method.equals("play")) {
                PlayingItem item = new PlayingItem((Map<String, Object>) call.arguments);
                _playerViewContainer.play(item);
            } else if (call.method.equals("ready")) {
                result.success(null);
            } else if (call.method.equals("togglePause")) {
                Boolean pause = (Boolean) call.arguments;
                _playerViewContainer.togglePause(pause);
                result.success(null);
            } else if (call.method.equals("release")) {
                _playerViewContainer.release();
                result.success(null);
            } else {
                result.error("noMethodFound", "no related method found " + call.method, "");
            }
        } catch (Exception e) {
            result.error("methodError", "Call " + call.method + " failed with" + call.arguments.toString(), e);
        }

    }
}
