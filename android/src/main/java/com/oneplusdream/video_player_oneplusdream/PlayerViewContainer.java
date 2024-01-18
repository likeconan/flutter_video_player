package com.oneplusdream.video_player_oneplusdream;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.provider.Settings;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.view.GestureDetectorCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.ProcessLifecycleOwner;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.datasource.DataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.hls.HlsMediaSource;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.ui.PlayerControlView;
import androidx.media3.ui.PlayerView;


import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import java.util.Map;
import java.util.Random;

class PlayerViewContainer implements PlatformView {

    @NonNull
    private final FrameLayout view;
    @NonNull
    private final PlayerView playerView;
    @NonNull
    private final PlayerControlView playerControlView;
    @NonNull
    private final LinearLayout playViewControlContainer;
    @NonNull
    private final ImageButton fullscreenBtn;
    @NonNull
    private final ImageButton playNextBtn;
    @NonNull
    private final Button rateBtn;
    @NonNull
    private final LinearLayout playerViewTop;
    @NonNull
    private final ImageButton backBtn;
    @NonNull
    private final ImageButton posterBtn;
    @NonNull
    private TextView titleTextView;
    @NonNull
    private TextView marqueeTextView;

    @NonNull
    private RelativeLayout playerViewCenter;
    @NonNull
    private TextView timeSeekTextView;
    @NonNull
    private LinearLayout brightnessCon;
    @NonNull
    private LinearLayout volumeCon;
    @NonNull
    private View brightnessValueView;
    @NonNull
    private View volumeValueView;


    private Activity activity;
    @NonNull
    private final ExoPlayer player;
    @NonNull
    private final Context context;
    private Boolean isFullScreen = false;
    private BottomSheetDialog bottom;
    private CoordinatorLayout bottomLayout;
    private IOrientationListener listener;
    private OrientationReader reader;
    private String Tag = "OnePlusDreamPlayerView";
    @NonNull
    private PlayerSetting _setting;
    @NonNull
    MethodChannel _channel;

    @NonNull
    private WindowInsetsControllerCompat _windowInsetsController;
    @NonNull
    private GestureDetectorCompat mDetector;
    @NonNull
    AudioManager audioManager;


    float brightness = 0;
    int volume = 0;
    int maxVolume = 0;
    int viewWidth = 0;
    int viewHeight = 0;
    long gestureSeekTo = -1;
    boolean mIsHorizontalScrolling = false;
    boolean mIsVerticalScrolling = false;
    float density = 0;
    float speed = 1.0f;


    PlayerViewContainer(@NonNull Context ctx, @Nullable Map<String, Object> creationParams, Activity act, MethodChannel channel) {
        context = ctx;
        activity = act;
        view = (FrameLayout) View.inflate(context, R.layout.player_view, null);
        marqueeTextView = (TextView) View.inflate(context, R.layout.marquee_text, null);
        playerViewTop = (LinearLayout) View.inflate(context, R.layout.player_top, null);
        titleTextView = playerViewTop.findViewById(R.id.title_text);
        backBtn = playerViewTop.findViewById(R.id.back_btn);
        posterBtn = view.findViewById(R.id.video_poster);

        playerViewCenter = (RelativeLayout) View.inflate(context, R.layout.player_center, null);
        timeSeekTextView = playerViewCenter.findViewById(R.id.time_seek_text);
        brightnessCon = playerViewCenter.findViewById(R.id.brightness_con);
        brightnessValueView = playerViewCenter.findViewById(R.id.brightness_value);
        volumeCon = playerViewCenter.findViewById(R.id.volume_con);
        volumeValueView = playerViewCenter.findViewById(R.id.volume_value);

        playerView = view.findViewById(R.id.player_view);
        playerControlView = playerView.findViewById(R.id.exo_controller);
        playViewControlContainer = playerControlView.findViewById(R.id.player_controller_container);
        fullscreenBtn = playerControlView.findViewById(R.id.fullscreen_btn);
        playNextBtn = (ImageButton) View.inflate(context, R.layout.play_next_button, null);
        rateBtn = (Button) View.inflate(context, R.layout.rate_button, null);
        playerView.addView(playerViewTop);
        playerView.addView(playerViewCenter);
        playerView.addView(marqueeTextView);
        playerControlView.setAnimationEnabled(false);


        player = new ExoPlayer.Builder(context).build();
        _channel = channel;
        initBottomSheetView();

        // TODO used for immersive mode
        _windowInsetsController = WindowCompat.getInsetsController(activity.getWindow(), activity.getWindow().getDecorView());
        _windowInsetsController.setSystemBarsBehavior(WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);

        // brightness
        WindowManager.LayoutParams layout = activity.getWindow().getAttributes();
        brightness = layout.screenBrightness;

        // audio
        audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        volume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
        maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        density = context.getResources().getDisplayMetrics().density;
        try {
            _setting = new PlayerSetting(creationParams);
            initPlayer();
            bindEvents();
        } catch (Exception e) {
            // TODO, show error message inview
            Log.e(Tag, "Error init player " + e.getMessage());
        }
    }

    private void initPlayer() {
        playerView.setPlayer(player);
        playerView.setControllerHideOnTouch(false);
        if (_setting.enablePreventScreenCapture) {
            ((SurfaceView) playerView.getVideoSurfaceView()).setSecure(true);
        }
        CustomDataSourceFactory httpDataSourceFactory =
                new CustomDataSourceFactory(_channel, activity);
        DataSource.Factory dataSourceFactory = () -> {
            CustomDataSource dataSource = httpDataSourceFactory.createDataSource();
            return dataSource;
        };
        for (PlayingItem item : _setting.playingItems) {
            MediaSource mediaSource = new HlsMediaSource.Factory(dataSourceFactory).createMediaSource(new MediaItem.Builder()
                    .setUri(item.url)
                    .setMediaMetadata(new MediaMetadata.Builder().setTitle(item.title).build())
                    .setMediaId(item.id)
                    .build());
            player.addMediaSource(mediaSource);
        }
        player.prepare();
        if (_setting.autoPlay) {
            player.play();
        } else {
            if (!Utils.IsStringEmpty(_setting.posterImage)) {
                Utils.setNetworkImage(_setting.posterImage, posterBtn);
            } else {
                posterBtn.setBackgroundResource(R.drawable.video_poster);
            }
            posterBtn.setVisibility(View.VISIBLE);
        }
        if (_setting.hideBackButton) {
            backBtn.setVisibility(View.INVISIBLE);
        }
        long pos = (long) (_setting.playingItems.get(_setting.initialPlayIndex).position * 1000.0);
        player.seekTo(_setting.initialPlayIndex, pos);
        titleTextView.setText(_setting.playingItems.get(_setting.initialPlayIndex).title);

        player.addListener(new Player.Listener() {
            @Override
            public void onPlayerError(PlaybackException error) {
                Player.Listener.super.onPlayerError(error);
                onPlayingEvent(PlayingStatus.ERROR);
                playerView.setCustomErrorMessage("Some wrong happened: " + error.getMessage());
            }

            @Override
            public void onIsPlayingChanged(boolean isPlaying) {
                if (isPlaying) {
                    playerView.setCustomErrorMessage(null);
                    onPlayingEvent(PlayingStatus.PLAY);
                    if (_setting.enableMarquee) {
                        startMarquee();
                    }
                } else {
                    int state = player.getPlaybackState();
                    if (state == Player.STATE_ENDED) {
                        onPlayingEvent(PlayingStatus.END);
                    } else {
                        onPlayingEvent(PlayingStatus.PAUSE);
                    }
                }
            }

            @Override
            public void onMediaItemTransition(@Nullable MediaItem mediaItem, int reason) {
                Player.Listener.super.onMediaItemTransition(mediaItem, reason);
                togglePlayNextBtn();
                titleTextView.setText(mediaItem.mediaMetadata.title);
            }
        });
        playerView.setControllerVisibilityListener((PlayerView.ControllerVisibilityListener) visibility -> playerViewTop.setVisibility(visibility));
    }

    private void togglePlayNextBtn() {
        boolean shouldAdd = isFullScreen && player.hasNextMediaItem() && playViewControlContainer.indexOfChild(playNextBtn) < 0;
        if (shouldAdd) {
            playViewControlContainer.addView(playNextBtn, 1);
        } else if (!isFullScreen || !player.hasNextMediaItem()) {
            playViewControlContainer.removeView(playNextBtn);
        }
    }

    private void onPlayingEvent(PlayingStatus status) {
        try {
            PlayingItem item = _setting.playingItems.get(player.getCurrentMediaItemIndex());
            _channel.invokeMethod("onPlaying", new PlayingEvent(item, player.getCurrentPosition() / 1000.0, status, player.getDuration() / 1000.0).toMap());
        } catch (Exception e) {
            // TODO invoke to log
            Log.e(Tag, "onPlaying event error: " + e.getMessage());
        }
    }

    private void initBottomSheetView() {
        bottom = new BottomSheetDialog(activity);
        BottomSheetBehavior<View> bottomSheetBehavior;
        View bottomSheetView = View.inflate(activity, R.layout.player_fullscreen, null);
        bottom.setContentView(bottomSheetView);
        bottomSheetBehavior = BottomSheetBehavior.from((View) bottomSheetView.getParent());
        bottomSheetBehavior.setDraggable(false);
        bottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        CoordinatorLayout layout = bottomSheetView.findViewById(R.id.bottomSheetLayout);
        assert layout != null;
        layout.setMinimumHeight(Resources.getSystem().getDisplayMetrics().heightPixels);
        bottomLayout = layout;
        bottom.setOnDismissListener((res) -> {
            if (isFullScreen) {
                changeScreenOrientation();
            }
            bottomLayout.removeView(playerView);
            getView().addView(playerView);
        });
    }


    private void bindEvents() {
        fullscreenBtn.setOnClickListener(v -> {
            changeScreenOrientation();
        });

        ProcessLifecycleOwner.get().getLifecycle().addObserver((LifecycleEventObserver) (source, event) -> {
            if (event == Lifecycle.Event.ON_PAUSE) {
                togglePause(true);
            } else if (event == Lifecycle.Event.ON_RESUME) {
                togglePause(false);
            }
        });

        reader = new OrientationReader(context);
        listener = new OrientationListener(reader, context, orientation -> {
            if (bottom == null || bottomLayout == null) {
                initBottomSheetView();
            }
            isFullScreen = orientation == NativeOrientation.LandscapeLeft || orientation == NativeOrientation.LandscapeRight;
            togglePlayNextBtn();
            if (isFullScreen) {
                playViewControlContainer.addView(rateBtn, 5);
                bottom.show();
                getView().removeView(playerView);
                bottomLayout.addView(playerView);
            } else {
                playViewControlContainer.removeView(rateBtn);
                bottom.dismiss();
            }
        });

        playNextBtn.setOnClickListener(v -> {
            player.seekToNextMediaItem();
        });

        listener.startOrientationListener();

        backBtn.setOnClickListener(v -> {
            if (isFullScreen) {
                changeScreenOrientation();
            } else {
                _channel.invokeMethod("onBack", null);
            }
        });

        posterBtn.setOnClickListener(v -> {
            player.play();
            posterBtn.setVisibility(View.INVISIBLE);
        });


        rateBtn.setOnClickListener(v -> {
            rateBtn.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
            if (speed == 1.0f) {
                player.setPlaybackSpeed(1.25f);
                rateBtn.setText("x1.25");
                speed = 1.25f;
            } else if (speed == 1.25f) {
                player.setPlaybackSpeed(1.50f);
                rateBtn.setText("x1.50");
                speed = 1.5f;
            } else if (speed == 1.50) {
                player.setPlaybackSpeed(2.0f);
                rateBtn.setText("x2.0");
                speed = 2.0f;
            } else if (speed == 2.0) {
                player.setPlaybackSpeed(1.0f);
                speed = 1.0f;
                rateBtn.setText("x1.0");
            }
            _channel.invokeMethod("onRateChange", speed);
        });


        // touch events
        mDetector = new GestureDetectorCompat(context, new MyGestureListener());

        playerView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (mDetector.onTouchEvent(motionEvent)) {
                    return true;
                }
                if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                    if (mIsHorizontalScrolling) {
                        mIsHorizontalScrolling = false;
                        Log.d(Tag, "Finish x scrolling");
                        timeSeekTextView.setVisibility(View.INVISIBLE);
                        player.seekTo(gestureSeekTo);
                        gestureSeekTo = -1;
                    }
                    if (mIsVerticalScrolling) {
                        mIsVerticalScrolling = false;
                        brightnessCon.setVisibility(View.INVISIBLE);
                        volumeCon.setVisibility(View.INVISIBLE);
                    }
                }
                return false;
            }
        });
    }

    private void toggleImmersive(boolean isFullScreen) {
        // TODO try with other android devices
        if (isFullScreen) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                _windowInsetsController.hide(WindowInsetsCompat.Type.systemBars());
            } else {
//                bottom.getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
//                        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE);
//                bottom.getWindow().getDecorView().setSystemUiVisibility(
//                        activity.getWindow().getDecorView().getSystemUiVisibility()
//                );
//                bottom.getWindow().getDecorView().setSystemUiVisibility(
//                        View.SYSTEM_UI_FLAG_LAYOUT_STABLE
//                                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
//                                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
//                                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
//                                | View.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
//                                | View.SYSTEM_UI_FLAG_IMMERSIVE
//                );
            }
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                _windowInsetsController.show(WindowInsetsCompat.Type.systemBars());
            } else {
                activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            }
        }
    }

    public void toggleFullScreen() {
        changeScreenOrientation();
    }

    public void release() {
        player.stop();
        onPlayingEvent(PlayingStatus.RELEASE);
        playerView.setPlayer(null);
    }

    private void changeScreenOrientation() {
        int orientation = activity.getResources().getConfiguration().orientation;
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        } else {
            activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }
        if (Settings.System.getInt(activity.getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0) == 1) {
            Handler handler = new Handler();
            handler.postDelayed(() -> activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR), 4000);
        }
    }

    public void play(PlayingItem item) {
        MediaItem mediaItem = MediaItem.fromUri(item.url);
        titleTextView.setText(item.title);
        player.setMediaItem(mediaItem);
        if (item.position > 0) {
            player.seekTo((long) (item.position * 1000));
        }
        player.play();
    }


    @NonNull
    @Override
    public FrameLayout getView() {
        view.post(() -> {
            viewWidth = view.getWidth();
            viewHeight = view.getHeight();

        });
        return view;
    }

    public void togglePause(boolean pause) {
        if (pause) {
            player.pause();
        } else {
            player.play();
        }
    }

    private void startMarquee() {
        marqueeTextView.setVisibility(_setting.enableMarquee ? View.VISIBLE : View.INVISIBLE);
        if (!_setting.enableMarquee && !Utils.IsStringEmpty(_setting.marqueeText)) {
            return;
        }
        marqueeTextView.setX(0);
        marqueeTextView.setText(Utils.generateColorfulText(_setting.marqueeText));
        float txtWidth = marqueeTextView.getWidth();
        int randomY = new Random().nextInt((int) Math.max(10, (viewHeight - 48)));
        marqueeTextView.setTranslationY(randomY);
        final ValueAnimator animator = ValueAnimator.ofFloat(-txtWidth, viewWidth + txtWidth);
        animator.setInterpolator(new LinearInterpolator());
        animator.setDuration((long) (8 * (isFullScreen ? 1.2 : 1) * 1000));
        animator.addUpdateListener(animation -> {
            final float progress = (float) animation.getAnimatedValue();
            marqueeTextView.setTranslationX(progress);
        });
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                startMarquee();
            }
        });
        animator.start();
    }

    @Override
    public void dispose() {
        Log.d(Tag, "Dispose in here");
    }

    class MyGestureListener extends GestureDetector.SimpleOnGestureListener {

        @Override
        public boolean onDoubleTap(MotionEvent e) {
            togglePause(player.isPlaying());
            return true;
        }

        int called = 0;

        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
            if (Math.abs(distanceX) < 0.5 && !mIsHorizontalScrolling) {
                mIsVerticalScrolling = true;
                boolean isRight = viewWidth / 2 < e1.getX();
                called++;
                if (called < 3) {
                    return true;
                }
                if (isRight) {
                    volumeCon.setVisibility(View.VISIBLE);
                    int v = Math.max(0, Math.min(maxVolume, volume + (distanceY > 0 ? 1 : -1)));
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, v, 0);
                    ViewGroup.LayoutParams viewLay = volumeValueView.getLayoutParams();
                    viewLay.height = (int) (density * 100 / maxVolume * v);
                    volumeValueView.setLayoutParams(viewLay);
                    volume = v;
                } else {
                    brightnessCon.setVisibility(View.VISIBLE);
                    float v = Math.max(-1F, Math.min(1F, brightness + (distanceY > 0 ? 0.2f : -0.2f)));
                    WindowManager.LayoutParams layout = activity.getWindow().getAttributes();
                    layout.screenBrightness = v;
                    activity.getWindow().setAttributes(layout);
                    ViewGroup.LayoutParams viewLay = brightnessValueView.getLayoutParams();
                    viewLay.height = (int) (density * 50 * (v + 1));
                    brightnessValueView.setLayoutParams(viewLay);
                    brightness = v;
                }
                called = 0;
            } else if (Math.abs(distanceY) < 0.5 && !mIsVerticalScrolling) {
                mIsHorizontalScrolling = true;
                long duration = player.getDuration();
                long current = player.getCurrentPosition();
                if (gestureSeekTo < 0) {
                    gestureSeekTo = current;
                }
                gestureSeekTo = Math.min(duration, Math.max(0, gestureSeekTo - (long) ((distanceX * 1000))));
                timeSeekTextView.setText(Utils.formatTimeUnit(gestureSeekTo) + "  " + Utils.formatTimeUnit(duration));
                timeSeekTextView.setVisibility(View.VISIBLE);
            }
            return true;
        }
    }


}
