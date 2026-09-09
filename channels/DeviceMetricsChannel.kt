package com.abik.vaidhya.flutter_native_hybrid.channels

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.abik.vaidhya.flutter_native_hybrid.feature.metrics.MetricsCollector
import com.abik.vaidhya.flutter_native_hybrid.feature.metrics.NativeMetricsActivity

class DeviceMetricsChannel(
    private val context: Context,
    private val messenger: BinaryMessenger
) {
    private val methodChannelName = "com.abik.vaidhya.device_metrics"
    private val eventChannelName = "com.abik.vaidhya.device_metrics_stream"

    private val collector = MetricsCollector(context)
    private val mainHandler = Handler(Looper.getMainLooper())

    private var eventSink: EventChannel.EventSink? = null
    private var streamRunnable: Runnable? = null

    fun register() {
        // MethodChannel (one-shot)
        MethodChannel(messenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentMetrics" -> {
                    try {
                        result.success(collector.collect())
                    } catch (e: Exception) {
                        result.error("METRICS_ERROR", e.message, null)
                    }
                }
                "openNativeMetricsScreen" -> {
                    try {
                        val intent = Intent(context, NativeMetricsActivity::class.java)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("OPEN_SCREEN_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel (live stream)
        EventChannel(messenger, eventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startStreaming()
                }

                override fun onCancel(arguments: Any?) {
                    stopStreaming()
                    eventSink = null
                }
            }
        )
    }

    private fun startStreaming() {
        stopStreaming()
        streamRunnable = object : Runnable {
            override fun run() {
                try {
                    eventSink?.success(collector.collect())
                } catch (e: Exception) {
                    eventSink?.error("STREAM_ERROR", e.message, null)
                }
                mainHandler.postDelayed(this, 2000)
            }
        }
        mainHandler.post(streamRunnable!!)
    }

    private fun stopStreaming() {
        streamRunnable?.let { mainHandler.removeCallbacks(it) }
        streamRunnable = null
    }
}