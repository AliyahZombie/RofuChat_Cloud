package com.rofu.rofuchat

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rofu/device").setMethodCallHandler { call, result ->
            if (call.method == "info") {
                val info = HashMap<String, Any?>()
                info["watch"] = packageManager.hasSystemFeature(PackageManager.FEATURE_WATCH)
                info["round"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) resources.configuration.isScreenRound else null
                result.success(info)
            } else {
                result.notImplemented()
            }
        }
    }
}
