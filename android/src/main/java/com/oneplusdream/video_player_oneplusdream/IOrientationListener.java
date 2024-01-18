package com.oneplusdream.video_player_oneplusdream;

public interface IOrientationListener {

    interface OrientationCallback {
        void receive(NativeOrientation orientation);
    }

    void startOrientationListener();

    void stopOrientationListener();
}

