package com.abik.vaidhya.flutter_native_hybrid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // device metric channel
        DeviceMetricsChannel(
            context = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger
        ).register()

        // bluetooth channel
        BleChannel(
            context = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger
        ).register()
    }
}