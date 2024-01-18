package com.oneplusdream.video_player_oneplusdream;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * VideoPlayerOneplusdreamPlugin
 */
public class VideoPlayerOneplusdreamPlugin implements FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    @NonNull
    private FlutterVideoPlayerView flutterVideoPlayerView;
    /// The MethodChannel that will the communication between Flutter and native Android
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterVideoPlayerView = new FlutterVideoPlayerView(flutterPluginBinding);
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("oneplusdream/video_player_android", flutterVideoPlayerView);
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "oneplusdream/global_channel");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        flutterVideoPlayerView.setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // TODO
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("cache")) {
            result.success("TODO not implemented " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("cancelCache")) {
            result.success("TODO not implemented " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("clearAllCache")) {
            result.success("TODO not implemented " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }
}
