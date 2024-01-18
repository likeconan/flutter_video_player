package com.oneplusdream.video_player_oneplusdream;

import static androidx.media3.datasource.cache.CacheDataSource.*;

import android.app.Activity;

import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.cache.CacheDataSource;

import io.flutter.plugin.common.MethodChannel;

public class CustomDataSourceFactory implements DataSource.Factory {

    MethodChannel _channel;
    Activity _activity;

    CustomDataSourceFactory(MethodChannel channel, Activity activity) {
        _channel = channel;
        _activity = activity;
    }

    @Override
    public CustomDataSource createDataSource() {
        return new CustomDataSource(_channel, _activity);
    }
}

