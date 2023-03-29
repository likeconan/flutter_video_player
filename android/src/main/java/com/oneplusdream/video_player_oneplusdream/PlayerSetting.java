package com.oneplusdream.video_player_oneplusdream;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class PlayerSetting {
    Boolean autoPlay;
    String protectionText;
    Boolean enablePreventScreenCapture;
    String marqueeText;
    Boolean enableMarquee;
    List<PlayingItem> playingItems;
    Integer initialPlayIndex;
    String lastPlayMessage;
    String posterImage;
    Boolean hideBackButton;

    PlayerSetting(@NonNull Map<String, Object> params) {
        this.autoPlay = (Boolean) params.get("autoPlay");
        this.protectionText = (String) params.get("protectionText");
        this.enablePreventScreenCapture = (Boolean) params.get("enablePreventScreenCapture");
        this.marqueeText = (String) params.get("marqueeText");
        this.enableMarquee = (Boolean) params.get("enableMarquee");
        this.initialPlayIndex = (Integer) params.getOrDefault("initialPlayIndex", 0);
        ArrayList<Map<String, Object>> items = (ArrayList<Map<String, Object>>) params.get("playingItems");
        List<PlayingItem> playingItems = new ArrayList<>();
        for (Map<String, Object> item :
                items) {
            playingItems.add(new PlayingItem(item));
        }
        this.playingItems = playingItems;
        this.lastPlayMessage = (String) params.get("lastPlayMessage");
        this.posterImage = (String) params.get("posterImage");
        this.hideBackButton = (Boolean) params.get("hideBackButton");

    }
}
