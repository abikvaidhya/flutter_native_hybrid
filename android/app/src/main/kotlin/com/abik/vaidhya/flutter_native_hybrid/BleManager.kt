package com.abik.vaidhya.flutter_native_hybrid

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper

class BleManager(
    private val context: Context,
    private val onEvent: (Map<String, Any?>) -> Unit
) {
    private val bluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val adapter: BluetoothAdapter? = bluetoothManager.adapter
    private val scanner get() = adapter?.bluetoothLeScanner

    private var gatt: BluetoothGatt? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var scanning = false

    private val scanCallback = object : ScanCallback() {
        @SuppressLint("MissingPermission")
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device ?: return
            val name = device.name ?: result.scanRecord?.deviceName
            onEvent(
                mapOf(
                    "type" to "deviceFound",
                    "name" to (name ?: "Unknown"),
                    "address" to device.address,
                    "rssi" to result.rssi
                )
            )
        }

        override fun onScanFailed(errorCode: Int) {
            onEvent(
                mapOf(
                    "type" to "error",
                    "message" to "Scan failed (code $errorCode)"
                )
            )
            scanning = false
        }
    }

    private val gattCallback = object : BluetoothGattCallback() {
        @SuppressLint("MissingPermission")
        override fun onConnectionStateChange(g: BluetoothGatt, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                onEvent(mapOf("type" to "connectionState", "state" to "connected"))
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                onEvent(mapOf("type" to "connectionState", "state" to "disconnected"))
                g.close()
                if (gatt === g) gatt = null
            }
        }
    }

    fun isEnabled(): Boolean = adapter?.isEnabled == true

    @SuppressLint("MissingPermission")
    fun startScan() {
        if (adapter == null || !adapter.isEnabled) {
            onEvent(mapOf("type" to "error", "message" to "Bluetooth is off"))
            return
        }
        if (scanning) return

        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()

        scanner?.startScan(null, settings, scanCallback)
        scanning = true

        // Auto-stop after 15s
        mainHandler.postDelayed({ stopScan() }, 15_000)
    }

    @SuppressLint("MissingPermission")
    fun stopScan() {
        if (!scanning) return
        try {
            scanner?.stopScan(scanCallback)
        } catch (_: Exception) {
        }
        scanning = false
        onEvent(mapOf("type" to "scanStopped"))
    }

    @SuppressLint("MissingPermission")
    fun connect(address: String) {
        val device: BluetoothDevice = try {
            adapter?.getRemoteDevice(address)
        } catch (_: Exception) {
            null
        } ?: run {
            onEvent(
                mapOf(
                    "type" to "connectionState",
                    "state" to "error",
                    "message" to "Invalid address"
                )
            )
            return
        }

        stopScan()
        onEvent(mapOf("type" to "connectionState", "state" to "connecting"))

        gatt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            device.connectGatt(context, false, gattCallback, BluetoothDevice.TRANSPORT_LE)
        } else {
            @Suppress("DEPRECATION")
            device.connectGatt(context, false, gattCallback)
        }
    }

    @SuppressLint("MissingPermission")
    fun disconnect() {
        gatt?.disconnect()
        gatt?.close()
        gatt = null
        onEvent(mapOf("type" to "connectionState", "state" to "disconnected"))
    }
}