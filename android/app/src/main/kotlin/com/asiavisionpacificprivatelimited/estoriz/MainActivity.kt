package com.asiavisionpacificprivatelimited.estoriz

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.estoriz/pip"
    private var pipEnabled = true
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "enable_auto_pip" -> {
                    pipEnabled = true
                    result.success(null)
                }
                "disable_auto_pip" -> {
                    pipEnabled = false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Called ONLY when user intentionally leaves the app
    // (home button, recent apps, swipe gesture).
    // NOT called for notification shade, incoming calls, or dialogs.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (!pipEnabled) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(16, 9))
                    .build()
                enterPictureInPictureMode(params)
            } catch (e: Exception) {
                // PiP not supported or failed — ignore silently
            }
        }
    }

    // Notify Flutter when PiP mode changes so Dart state stays in sync
 override fun onPictureInPictureModeChanged(
    isInPictureInPictureMode: Boolean,
    newConfig: Configuration
) {
    super.onPictureInPictureModeChanged(
        isInPictureInPictureMode,
        newConfig
    )

    if (isInPictureInPictureMode) {

        channel?.invokeMethod("pip_started", null)

    } else {

        channel?.invokeMethod("pip_stopped", null)

        // Delay check because some OEMs restore activity late
        window.decorView.postDelayed({
            // Check if the activity is resumed or started. If not, it was likely closed.
            if (!lifecycle.currentState.isAtLeast(androidx.lifecycle.Lifecycle.State.STARTED)) {
                channel?.invokeMethod("pip_closed", null)
            }
        }, 600)
    }
}
}
