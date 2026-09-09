import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ble_controller.dart';

class BleScanScreen extends GetView<BleController> {
  const BleScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth LE'),
        actions: [
          Obx(() {
            if (controller.connectionState.value == 'connected') {
              return TextButton(
                onPressed: controller.disconnect,
                child: const Text('Disconnect'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (!controller.adapterEnabled.value) {
                return Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const ListTile(
                    leading: Icon(Icons.bluetooth_disabled),
                    title: Text('Bluetooth is off'),
                    subtitle: Text('Turn on Bluetooth and try again'),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 8),
            Obx(() {
              final state = controller.connectionState.value;
              final addr = controller.connectedAddress.value;
              if (state == 'disconnected' && addr == null) {
                return const SizedBox.shrink();
              }
              return Card(
                child: ListTile(
                  leading: Icon(
                    state == 'connected'
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_searching,
                  ),
                  title: Text('Status: $state'),
                  subtitle: addr != null ? Text(addr) : null,
                ),
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final err = controller.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  err,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }),
            Obx(
                  () => FilledButton.icon(
                onPressed: controller.isScanning.value
                    ? controller.stopScan
                    : controller.startScan,
                icon: Icon(
                  controller.isScanning.value ? Icons.stop : Icons.radar,
                ),
                label: Text(
                  controller.isScanning.value ? 'Stop scan' : 'Start scan',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Devices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.devices.isEmpty) {
                  return Center(
                    child: Text(
                      controller.isScanning.value
                          ? 'Scanning…'
                          : 'No devices yet.\nTap Start scan.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: controller.devices.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final d = controller.devices[index];
                    return ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: Text(d.name),
                      subtitle: Text('${d.address}  ·  RSSI ${d.rssi}'),
                      trailing: Obx(() {
                        final connected =
                            controller.connectedAddress.value == d.address &&
                                controller.connectionState.value == 'connected';
                        if (connected) {
                          return const Chip(label: Text('Connected'));
                        }
                        return TextButton(
                          onPressed: () => controller.connect(d),
                          child: const Text('Connect'),
                        );
                      }),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}