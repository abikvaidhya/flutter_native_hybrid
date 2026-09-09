import 'package:flutter/services.dart';

// Thin wrapper around the MethodChannel / EventChannel.
// This is the ONLY place in the Flutter code that talks to native.
// Controllers and UI never call MethodChannel directly.

class DeviceMetricsChannel {
  static const _methodChannel = MethodChannel(
    'com.abik.vaidhya.device_metrics',
  );
  static const _eventChannel = EventChannel(
    'com.abik.vaidhya.device_metrics_stream',
  );

  // One-shot call: ask native for current metrics snapshot
  Future<Map<String, dynamic>> getCurrentMetrics() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>(
        'getCurrentMetrics',
      );
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw DeviceMetricsException(
        code: e.code,
        message: e.message ?? 'Failed to get metrics',
        details: e.details,
      );
    }
  }

  // Ask native to open a full-screen Jetpack Compose activity
  Future<void> openNativeMetricsScreen() async {
    try {
      await _methodChannel.invokeMethod('openNativeMetricsScreen');
    } on PlatformException catch (e) {
      throw DeviceMetricsException(
        code: e.code,
        message: e.message ?? 'Failed to open native screen',
        details: e.details,
      );
    }
  }

  // Continuous stream of metrics (battery, memory, etc.)
  Stream<Map<String, dynamic>> metricsStream() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }
}

class DeviceMetricsException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  DeviceMetricsException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'DeviceMetricsException($code): $message';
}
