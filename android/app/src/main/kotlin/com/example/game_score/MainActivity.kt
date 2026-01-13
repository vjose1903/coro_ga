package com.inSpot.coro_games

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.inSpot.coro_games/icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setIcon") {
                val iconName = call.argument<String>("iconName")
                if (iconName != null) {
                    setIcon(iconName)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "iconName is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setIcon(iconName: String) {
        val packageManager = packageManager
        val packageName = packageName

        // Lista de todos los activity-alias disponibles
        val activities = listOf("MainActivity", "MainActivityPremium")

        for (activity in activities) {
            val componentName = ComponentName(packageName, "$packageName.$activity")
            val newState = if (activity == iconName) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            
            try {
                packageManager.setComponentEnabledSetting(
                    componentName,
                    newState,
                    PackageManager.DONT_KILL_APP
                )
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
