class BluetoothDeviceInfo {
  final String name;
  final String serialNumber;
  final String id;
  final bool isConnected;

  const BluetoothDeviceInfo({
    required this.name,
    required this.serialNumber,
    required this.id,
    required this.isConnected,
  });

  BluetoothDeviceInfo copyWith({
    String? name,
    String? serialNumber,
    String? id,
    bool? isConnected,
  }) {
    return BluetoothDeviceInfo(
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      id: id ?? this.id,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BluetoothDeviceInfo &&
        other.name == name &&
        other.serialNumber == serialNumber &&
        other.id == id &&
        other.isConnected == isConnected;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        serialNumber.hashCode ^
        id.hashCode ^
        isConnected.hashCode;
  }

  @override
  String toString() {
    return 'BluetoothDeviceInfo('
        'name: $name, '
        'serialNumber: $serialNumber, '
        'id: $id, '
        'isConnected: $isConnected)';
  }
}