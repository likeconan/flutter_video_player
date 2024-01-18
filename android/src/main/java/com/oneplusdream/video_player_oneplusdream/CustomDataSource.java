package com.oneplusdream.video_player_oneplusdream;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.util.Log;

import androidx.media3.datasource.DataSpec;
import androidx.media3.datasource.DefaultHttpDataSource;

import io.flutter.plugin.common.MethodChannel;

public class CustomDataSource extends DefaultHttpDataSource {
    private MethodChannel _channel;
    private Activity _activity;

    CustomDataSource(MethodChannel channel, Activity activity) {
        _channel = channel;
        _activity = activity;
    }

    @Override
    public long open(DataSpec dataSpec) throws HttpDataSourceException {
        _activity.runOnUiThread(() -> {
            //call the methodChannel.invokeMethod here to avoid @UiThread exception
            _channel.invokeMethod("onUrlRequested", dataSpec.uri.toString());
        });
        return super.open(dataSpec);
    }
}
