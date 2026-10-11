package com.trace.raffine.trace_raffine

import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.function.Consumer

class MainActivity : FlutterActivity() {

    private companion object {
        const val SECURITY_CHANNEL = "trace_raffine/security_detection"
        const val EVENT_SCREENSHOT = "screenCaptureDetected"
        const val EVENT_SCREEN_RECORDING = "screenRecordingDetected"
    }

    private var securityChannel: MethodChannel? = null
    private var screenCaptureCallback: Activity.ScreenCaptureCallback? = null
    private var screenRecordingCallback: Consumer<Int>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        securityChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SECURITY_CHANNEL
        )
    }

    override fun onStart() {
        super.onStart()

        if (Build.VERSION.SDK_INT >= 34) {
            screenCaptureCallback = Activity.ScreenCaptureCallback {
                securityChannel?.invokeMethod(
                    EVENT_SCREENSHOT,
                    mapOf(
                        "platform" to "android",
                        "api" to Build.VERSION.SDK_INT
                    )
                )
            }

            registerScreenCaptureCallback(
                mainExecutor,
                screenCaptureCallback!!
            )
        }

        if (Build.VERSION.SDK_INT >= 35) {
            screenRecordingCallback = Consumer<Int> { state ->
                if (state == WindowManager.SCREEN_RECORDING_STATE_VISIBLE) {
                    securityChannel?.invokeMethod(
                        EVENT_SCREEN_RECORDING,
                        mapOf(
                            "platform" to "android",
                            "api" to Build.VERSION.SDK_INT
                        )
                    )
                }
            }

            val initialState = windowManager.addScreenRecordingCallback(
                mainExecutor,
                screenRecordingCallback!!
            )

            if (initialState == WindowManager.SCREEN_RECORDING_STATE_VISIBLE) {
                securityChannel?.invokeMethod(
                    EVENT_SCREEN_RECORDING,
                    mapOf(
                        "platform" to "android",
                        "api" to Build.VERSION.SDK_INT
                    )
                )
            }
        }
    }

    override fun onStop() {
        if (Build.VERSION.SDK_INT >= 34) {
            screenCaptureCallback?.let {
                unregisterScreenCaptureCallback(it)
            }
            screenCaptureCallback = null
        }

        if (Build.VERSION.SDK_INT >= 35) {
            screenRecordingCallback?.let {
                windowManager.removeScreenRecordingCallback(it)
            }
            screenRecordingCallback = null
        }

        super.onStop()
    }

    override fun onDestroy() {
        securityChannel?.setMethodCallHandler(null)
        securityChannel = null
        super.onDestroy()
    }
}
