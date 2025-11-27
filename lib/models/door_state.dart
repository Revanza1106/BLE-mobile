import '../core/services/bluetooth_service.dart';

class DoorState {
  final bool isConnected;
  final DoorStatus status;
  final bool isOperating;
  final bool isAlwaysOpen;
  final String displayStatus;
  final String? errorMessage;

  const DoorState({
    required this.isConnected,
    required this.status,
    required this.isOperating,
    required this.isAlwaysOpen,
    required this.displayStatus,
    this.errorMessage,
  });

  DoorState copyWith({
    bool? isConnected,
    DoorStatus? status,
    bool? isOperating,
    bool? isAlwaysOpen,
    String? displayStatus,
    String? errorMessage,
  }) {
    return DoorState(
      isConnected: isConnected ?? this.isConnected,
      status: status ?? this.status,
      isOperating: isOperating ?? this.isOperating,
      isAlwaysOpen: isAlwaysOpen ?? this.isAlwaysOpen,
      displayStatus: displayStatus ?? this.displayStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory DoorState.initial() {
    return const DoorState(
      isConnected: false,
      status: DoorStatus.disconnected,
      isOperating: false,
      isAlwaysOpen: false,
      displayStatus: "Disconnected",
    );
  }

  factory DoorState.fromStatus(DoorStatus status, {bool isConnected = false}) {
    String displayStatus;
    String? errorMessage;

    switch (status) {
      case DoorStatus.disconnected:
        displayStatus = "Disconnected";
        break;
      case DoorStatus.scanning:
        displayStatus = "Scanning...";
        break;
      case DoorStatus.connecting:
        displayStatus = "Connecting...";
        break;
      case DoorStatus.connected:
        displayStatus = "Connected";
        break;
      case DoorStatus.locked:
        displayStatus = "Locked";
        break;
      case DoorStatus.open:
        displayStatus = "Open";
        break;
      case DoorStatus.error:
        displayStatus = "Error";
        errorMessage = "Connection error occurred";
        break;
      case DoorStatus.deviceNotFound:
        displayStatus = "Device Not Found";
        errorMessage = "No devices found nearby";
        break;
      case DoorStatus.serialMismatch:
        displayStatus = "Serial Mismatch";
        errorMessage = "Device serial doesn't match saved serial";
        break;
    }

    return DoorState(
      isConnected: isConnected,
      status: status,
      isOperating: false,
      isAlwaysOpen: false,
      displayStatus: displayStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoorState &&
        other.isConnected == isConnected &&
        other.status == status &&
        other.isOperating == isOperating &&
        other.isAlwaysOpen == isAlwaysOpen &&
        other.displayStatus == displayStatus &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^
        status.hashCode ^
        isOperating.hashCode ^
        isAlwaysOpen.hashCode ^
        displayStatus.hashCode ^
        errorMessage.hashCode;
  }

  @override
  String toString() {
    return 'DoorState('
        'isConnected: $isConnected, '
        'status: $status, '
        'isOperating: $isOperating, '
        'isAlwaysOpen: $isAlwaysOpen, '
        'displayStatus: $displayStatus, '
        'errorMessage: $errorMessage)';
  }
}