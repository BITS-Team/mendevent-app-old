package com.example.flutter_app;

import android.os.Bundle;
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
//  private static final String CHANNEL = "mn.mend.assistant/qrscan";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
//    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//            .setMethodCallHandler(
//                    (call, result) -> {
//                      // TODO
//                    }
//            );
  }
}
