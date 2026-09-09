package com.abik.vaidhya.flutter_native_hybrid

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class BleChannel(
    private val context: Context,
    private val messenger: BinaryMessenger
) {
    private val methodChannelName = "com.abik.vaidhya/ble"
    private val eventChannelName = "com.abik.vaidhya/ble_stream"

    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null

    private val bleManager = BleManager(context) { event ->
        mainHandler.post {
            eventSink?.success(event)
        }
    }

    fun register() {
        MethodChannel(messenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "startScan" -> {
                    try {
                        bleManager.startScan()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SCAN_ERROR", e.message, null)
                    }
                }
                "stopScan" -> {
                    try {
                        bleManager.stopScan()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SCAN_ERROR", e.message, null)
                    }
                }
                "connect" -> {
                    val address = call.argument<String>("address")
                    if (address.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "address required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        bleManager.connect(address)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("CONNECT_ERROR", e.message, null)
                    }
                }
                "disconnect" -> {
                    try {
                        bleManager.disconnect()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("DISCONNECT_ERROR", e.message, null)
                    }
                }
                "getAdapterState" -> {
                    result.success(mapOf("enabled" to bleManager.isEnabled()))
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, eventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    bleManager.stopScan()
                }
            }
        )
    }
}