package com.oneplusdream.video_player_oneplusdream;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class PlayingEvent {
    public PlayingItem playingItem;
    public Double currentPosition;
    public Double duration;
    public PlayingStatus status;

    public PlayingEvent(PlayingItem item, Double currentPosition, PlayingStatus status, Double duration) {
        this.playingItem = item;
        this.currentPosition = currentPosition;
        this.status = status;
        this.duration = duration;
    }

    public PlayingEvent(PlayingItem item) {
        this.playingItem = item;
    }

    public PlayingEvent(PlayingItem item, Double currentPosition) {
        this.playingItem = item;
        this.currentPosition = currentPosition;
    }

    public PlayingEvent(PlayingItem item, PlayingStatus status) {
        this.playingItem = item;
        this.status = status;
    }

    public Map<String, Object> toMap() {
        Map<String, Object> jo = new HashMap<>();
        jo.put("item", this.playingItem.toMap());
        jo.put("currentPosition", this.currentPosition);
        jo.put("status", this.status.ordinal());
        jo.put("duration", this.duration);
        return jo;
    }
}
