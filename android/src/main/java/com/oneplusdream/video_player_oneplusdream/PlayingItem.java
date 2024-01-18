package com.oneplusdream.video_player_oneplusdream;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class PlayingItem {
    @NonNull
    String url;
    @NonNull
    String id;
    String title;
    Double position;
    String extra;
    @NonNull
    int fitModel;
    Double aspectRatio;

    PlayingItem(@NonNull Map<String, Object> params) {
        this.url = (String) params.get("url");
        this.id = (String) params.get("id");
        this.title = (String) params.get("title");
        this.position = (Double) params.get("position");
        if (this.position == null) {
            this.position = 0.0;
        }
        this.extra = (String) params.get("extra");
        this.fitModel = (Integer) params.get("fitMode");
        this.aspectRatio = (Double) params.get("aspectRatio");
    }

    public Map<String, Object> toMap() {
        Map<String, Object> jo = new HashMap<>();
        jo.put("url", this.url);
        jo.put("id", this.id);
        jo.put("title", this.title);
        jo.put("position", this.position);
        jo.put("extra", this.extra);
        jo.put("fitMode", this.fitModel);
        jo.put("aspectRatio", this.aspectRatio);
        return jo;
    }
}

