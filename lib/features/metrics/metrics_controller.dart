import 'dart:async';

import 'package:get/get.dart';

import '../../platform/device_metric_channel.dart';

// GetX controller that owns all state for the metrics feature.
class MetricsController extends GetxController {
  final DeviceMetricsChannel _channel = DeviceMetricsChannel();

  // Observable state
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final metrics = Rxn<Map<String, dynamic>>();
  final isStreaming = false.obs;

  StreamSubscription? _streamSub;

  @override
  void onClose() {
    _streamSub?.cancel();
    super.onClose();
  }

  // One-shot fetch from native
  Future<void> fetchMetrics() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _channel.getCurrentMetrics();
      metrics.value = data;
    } on DeviceMetricsException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Open the full native Jetpack Compose screen
  Future<void> openNativeScreen() async {
    try {
      await _channel.openNativeMetricsScreen();
    } on DeviceMetricsException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Native Error', e.message);
    }
  }

  /// Start receiving live updates from native
  void startStreaming() {
    if (isStreaming.value) return;

    isStreaming.value = true;
    errorMessage.value = null;

    _streamSub = _channel.metricsStream().listen(
      (data) {
        metrics.value = data;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isStreaming.value = false;
      },
      onDone: () {
        isStreaming.value = false;
      },
    );
  }

  void stopStreaming() {
    _streamSub?.cancel();
    _streamSub = null;
    isStreaming.value = false;
  }
}
