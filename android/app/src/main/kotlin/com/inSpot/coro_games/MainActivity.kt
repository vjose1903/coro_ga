package com.inSpot.coro_games

import android.os.SystemClock
import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var lastBackKeyEventAtMs: Long = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.inSpot.coro_games/back_origin"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeBackButtonPress" -> {
                    val now = SystemClock.elapsedRealtime()
                    val wasBackButton = now - lastBackKeyEventAtMs <= 1000
                    if (wasBackButton) {
                        lastBackKeyEventAtMs = 0
                    }
                    result.success(wasBackButton)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.keyCode == KeyEvent.KEYCODE_BACK && event.action == KeyEvent.ACTION_UP) {
            lastBackKeyEventAtMs = SystemClock.elapsedRealtime()
        }
        return super.dispatchKeyEvent(event)
    }
}
