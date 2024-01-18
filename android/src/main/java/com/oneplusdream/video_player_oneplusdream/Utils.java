package com.oneplusdream.video_player_oneplusdream;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.text.Html;
import android.text.Spanned;
import android.widget.ImageButton;
import android.widget.ImageView;

import java.io.IOException;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class Utils {
    public static boolean IsStringEmpty(String val) {
        if (val == null || val.isEmpty() || val.trim().isEmpty()) {
            return true;
        } else {
            return false;
        }
    }

    public static void setNetworkImage(String url, ImageView btn) {
        // Declaring executor to parse the URL
        ExecutorService executor = Executors.newSingleThreadExecutor();
        // Once the executor parses the URL
        // and receives the image, handler will load it
        // in the ImageView
        Handler handler = new Handler(Looper.getMainLooper());

        // Only for Background process (can take time depending on the Internet speed)
        executor.execute(() -> {
            try {
                Bitmap image = BitmapFactory.decodeStream(new URL("https://media.geeksforgeeks.org/wp-content/cdn-uploads/gfg_200x200-min.png").openStream());
                handler.post(() -> btn.setImageBitmap(image));
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }

    public static String formatTimeUnit(long duration){
        String time = String.format("%02d:%02d",
                TimeUnit.MILLISECONDS.toMinutes(duration),
                TimeUnit.MILLISECONDS.toSeconds(duration) -
                        TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(duration))
        );
        return time;
    }

    public static Spanned generateColorfulText(String tempText) {

        String[] tempTextArr = tempText.split("");
        String newText = "";
        String[] colors = {"#f44336", "#9c27b0", "#673ab7", "#3f51b5", "#4caf50", "#cddc39", "#9e9e9e", "#607d8b", "#ff5722", "#795548"};

        for (int i = 0; i < tempTextArr.length; i++) {
            if (!tempTextArr[i].equals(" ")) {
                int v = 0 + (int) (Math.random() * ((9 - 0)));
                newText = newText + "<font color='" + colors[v] + "'>" + tempTextArr[i] + "</font>";
            } else {
                newText = newText + "";
            }
        }

        return Html.fromHtml(newText);
    }
}
