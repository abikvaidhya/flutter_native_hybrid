import 'dart:async';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../platform/ble_channel.dart';
import 'models/ble_device.dart';

class BleController extends GetxController {
  final BleChannel _channel = BleChannel();

  final isScanning = false.obs;
  final devices = <BleDevice>[].obs;
  final connectionState = 'disconnected'.obs;
  final connectedAddress = RxnString();
  final errorMessage = RxnString();
  final adapterEnabled = true.obs;

  StreamSubscription? _eventSub;

  @override
  void onInit() {
    super.onInit();
    _listenToEvents();
    checkAdapter();
  }

  @override
  void onClose() {
    _eventSub?.cancel();
    stopScan();
    super.onClose();
  }

  void _listenToEvents() {
    _eventSub = _channel.events().listen((event) {
      final type = event['type'] as String?;
      switch (type) {
        case 'deviceFound':
          final device = BleDevice.fromMap(event);
          final index = devices.indexWhere((d) => d.address == device.address);
          if (index >= 0) {
            devices[index] = device;
          } else {
            devices.add(device);
          }
          break;
        case 'scanStopped':
          isScanning.value = false;
          break;
        case 'connectionState':
          connectionState.value = event['state'] as String? ?? 'disconnected';
          if (connectionState.value == 'disconnected') {
            connectedAddress.value = null;
          }
          if (event['message'] != null) {
            errorMessage.value = event['message'] as String;
          }
          break;
        case 'error':
          errorMessage.value = event['message'] as String? ?? 'Unknown error';
          isScanning.value = false;
          break;
      }
    }, onError: (e) {
      errorMessage.value = e.toString();
      isScanning.value = false;
    });
  }

  Future<void> checkAdapter() async {
    try {
      adapterEnabled.value = await _channel.isAdapterEnabled();
    } catch (_) {
      adapterEnabled.value = false;
    }
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> startScan() async {
    errorMessage.value = null;
    final ok = await _ensurePermissions();
    if (!ok) {
      errorMessage.value = 'Bluetooth / Location permission required';
      return;
    }

    devices.clear();
    isScanning.value = true;
    try {
      await _channel.startScan();
    } on BleException catch (e) {
      errorMessage.value = e.message;
      isScanning.value = false;
    }
  }

  Future<void> stopScan() async {
    try {
      await _channel.stopScan();
    } catch (_) {}
    isScanning.value = false;
  }

  Future<void> connect(BleDevice device) async {
    errorMessage.value = null;
    connectionState.value = 'connecting';
    connectedAddress.value = device.address;
    try {
      await stopScan();
      await _channel.connect(device.address);
    } on BleException catch (e) {
      errorMessage.value = e.message;
      connectionState.value = 'error';
      connectedAddress.value = null;
    }
  }

  Future<void> disconnect() async {
    try {
      await _channel.disconnect();
    } on BleException catch (e) {
      errorMessage.value = e.message;
    }
  }
}