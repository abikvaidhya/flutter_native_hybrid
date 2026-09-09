import 'package:flutter/services.dart';

class BleChannel {
  static const _methodChannel = MethodChannel('com.abik.vaidhya/ble');
  static const _eventChannel = EventChannel('com.abik.vaidhya/ble_stream');

  Future<void> startScan() async {
    try {
      await _methodChannel.invokeMethod('startScan');
    } on PlatformException catch (e) {
      throw BleException(e.code, e.message ?? 'Failed to start scan');
    }
  }

  Future<void> stopScan() async {
    try {
      await _methodChannel.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      throw BleException(e.code, e.message ?? 'Failed to stop scan');
    }
  }

  Future<void> connect(String address) async {
    try {
      await _methodChannel.invokeMethod('connect', {'address': address});
    } on PlatformException catch (e) {
      throw BleException(e.code, e.message ?? 'Failed to connect');
    }
  }

  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw BleException(e.code, e.message ?? 'Failed to disconnect');
    }
  }

  Future<bool> isAdapterEnabled() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>('getAdapterState');
      return result?['enabled'] == true;
    } on PlatformException catch (e) {
      throw BleException(e.code, e.message ?? 'Failed to get adapter state');
    }
  }

  Stream<Map<String, dynamic>> events() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }
}

class BleException implements Exception {
  final String code;
  final String message;

  BleException(this.code, this.message);

  @override
  String toString() => 'BleException($code): $message';
}