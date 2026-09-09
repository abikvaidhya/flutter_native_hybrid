import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'metrics_controller.dart';

class MetricsScreen extends GetView<MetricsController> {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Metrics'),
        actions: [
          IconButton(
            tooltip: 'Open full native Compose screen',
            icon: const Icon(Icons.open_in_new),
            onPressed: controller.openNativeScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: controller.fetchMetrics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Fetch once'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                        () => FilledButton.tonalIcon(
                      onPressed: controller.isStreaming.value
                          ? controller.stopStreaming
                          : controller.startStreaming,
                      icon: Icon(
                        controller.isStreaming.value
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        controller.isStreaming.value
                            ? 'Stop stream'
                            : 'Live stream',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Loading / Error / Data
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: controller.fetchMetrics,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final data = controller.metrics.value;
                if (data == null) {
                  return Center(
                    child: Text(
                      'Press "Fetch once" or start the live stream\n'
                          'to receive data from the native side.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView(
                  children: [
                    _MetricCard(
                      title: 'Battery',
                      value: '${data['batteryLevel'] ?? '–'}%',
                      subtitle: data['isCharging'] == true
                          ? 'Charging'
                          : 'Not charging',
                      icon: Icons.battery_full,
                    ),
                    _MetricCard(
                      title: 'Available Memory',
                      value: _formatBytes(data['availableMemory']),
                      subtitle:
                      'of ${_formatBytes(data['totalMemory'])}',
                      icon: Icons.memory,
                    ),
                    _MetricCard(
                      title: 'Network',
                      value: data['networkType']?.toString() ?? '–',
                      subtitle: data['isConnected'] == true
                          ? 'Connected'
                          : 'Offline',
                      icon: Icons.wifi,
                    ),
                    _MetricCard(
                      title: 'Device',
                      value: data['model']?.toString() ?? '–',
                      subtitle: data['manufacturer']?.toString() ?? '',
                      icon: Icons.phone_android,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(dynamic value) {
    if (value == null) return '–';
    final bytes = value is int ? value : int.tryParse(value.toString()) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}