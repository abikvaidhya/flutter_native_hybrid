class BleDevice {
  final String name;
  final String address;
  final int rssi;

  const BleDevice({
    required this.name,
    required this.address,
    required this.rssi,
  });

  factory BleDevice.fromMap(Map<String, dynamic> map) {
    return BleDevice(
      name: (map['name'] as String?)?.isNotEmpty == true
          ? map['name'] as String
          : 'Unknown',
      address: map['address'] as String? ?? '',
      rssi: map['rssi'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleDevice && address == other.address;

  @override
  int get hashCode => address.hashCode;
}