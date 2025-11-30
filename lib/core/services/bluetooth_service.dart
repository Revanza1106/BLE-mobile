import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

enum DoorStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  locked,
  open,
  error,
  deviceNotFound,
  serialMismatch,
}

class DoorBluetoothService {
  static final DoorBluetoothService _instance = DoorBluetoothService._internal();
  factory DoorBluetoothService() => _instance;
  DoorBluetoothService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _controlCharacteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  final StreamController<DoorStatus> _doorStatusController = StreamController<DoorStatus>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<String> _notificationController = StreamController<String>.broadcast();

  Stream<DoorStatus> get doorStatusStream => _doorStatusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get notificationStream => _notificationController.stream;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  Future<bool> isBluetoothEnabled() async {
    try {
      return await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    } catch (e) {
      Logger.e('Failed to check Bluetooth status', error: e.toString(), tag: 'DoorBluetoothService');
      return false;
    }
  }

  Future<void> scanAndConnect(String expectedSerial, String? secret) async {
    if (_connectedDevice != null) {
      Logger.w('Already connected to a device', tag: 'DoorBluetoothService');
      return;
    }

    try {
      _updateDoorStatus(DoorStatus.scanning);
      Logger.i('Starting Bluetooth scan...', tag: 'DoorBluetoothService');

      await FlutterBluePlus.startScan(timeout: AppConstants.scanTimeout);

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        _onScanResults,
        onError: (error) {
          Logger.e('Scan error', error: error.toString(), tag: 'DoorBluetoothService');
          _updateDoorStatus(DoorStatus.error);
        },
      );

      // Stop scan after timeout
      await Future.delayed(const Duration(seconds: 8));
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();

      if (_connectedDevice == null) {
        Logger.i('No device found during scan', tag: 'DoorBluetoothService');
        _updateDoorStatus(DoorStatus.deviceNotFound);
      }
    } catch (e) {
      Logger.e('Scan failed', error: e.toString(), tag: 'DoorBluetoothService');
      _updateDoorStatus(DoorStatus.error);
    }
  }

  void _onScanResults(List<ScanResult> results) {
    for (var result in results) {
      if (result.device.platformName.isNotEmpty) {
        Logger.d('Found device: ${result.device.platformName}', tag: 'DoorBluetoothService');
        _connectToDevice(result.device);
        _scanSubscription?.cancel();
        return;
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _updateDoorStatus(DoorStatus.connecting);
      Logger.i('Connecting to device: ${device.platformName}', tag: 'DoorBluetoothService');

      await device.connect(timeout: AppConstants.connectTimeout);
      _connectedDevice = device;
      _connectionController.add(true);

      final services = await device.discoverServices();
      await _setupCharacteristics(services);

      _updateDoorStatus(DoorStatus.connected);
      Logger.i('Connected to device successfully', tag: 'DoorBluetoothService');
    } catch (e) {
      Logger.e('Connection failed', error: e.toString(), tag: 'DoorBluetoothService');
      await disconnect();
      _updateDoorStatus(DoorStatus.error);
    }
  }

  Future<void> _setupCharacteristics(List<BluetoothService> services) async {
    String? deviceSerial;

    for (var service in services) {
      if (service.uuid.toString().toLowerCase().contains(AppConstants.serviceUuid.substring(0, 8))) {
        for (var characteristic in service.characteristics) {
          final uuid = characteristic.uuid.toString().toLowerCase();

          if (uuid.contains(AppConstants.serialUuid.substring(0, 8))) {
            final bytes = await characteristic.read();
            deviceSerial = String.fromCharCodes(bytes).trim();
            Logger.i('Device serial: $deviceSerial', tag: 'DoorBluetoothService');
          }

          if (uuid.contains(AppConstants.controlUuid.substring(0, 8))) {
            _controlCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);

            _notificationSubscription = characteristic.lastValueStream.listen(
              _onNotificationReceived,
              onError: (error) {
                Logger.e('Notification error', error: error.toString(), tag: 'DoorBluetoothService');
              },
            );
          }
        }
      }
    }

    if (deviceSerial == null) {
      throw Exception('Serial characteristic not found');
    }

  }

  void _onNotificationReceived(List<int> data) {
    try {
      final value = String.fromCharCodes(data).trim();
      Logger.d('Bluetooth notification received: $value', tag: 'DoorBluetoothService');

      _notificationController.add(value);

      if (value.contains("Open")) {
        _updateDoorStatus(DoorStatus.open);
      } else {
        _updateDoorStatus(DoorStatus.locked);
      }
    } catch (e) {
      Logger.e('Failed to parse notification', error: e.toString(), tag: 'DoorBluetoothService');
    }
  }

  Future<void> sendCommand(String secret, String command) async {
    if (_controlCharacteristic == null) {
      Logger.e('No control characteristic available', tag: 'DoorBluetoothService');
      throw Exception('Not connected to device');
    }

    try {
      final payload = '${AppConstants.commandPrefix}${AppConstants.commandSeparator}$secret${AppConstants.commandSeparator}CMD${AppConstants.commandSeparator}$command';
      final bytes = payload.codeUnits;

      await _controlCharacteristic!.write(bytes, withoutResponse: false);
      Logger.i('Command sent: $command', tag: 'DoorBluetoothService');
    } catch (e) {
      Logger.e('Failed to send command', error: e.toString(), tag: 'DoorBluetoothService');
      throw Exception('Failed to send command: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _scanSubscription?.cancel();
      await _notificationSubscription?.cancel();
      _scanSubscription = null;
      _notificationSubscription = null;

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _controlCharacteristic = null;
      }

      _connectionController.add(false);
      _updateDoorStatus(DoorStatus.disconnected);
      Logger.i('Disconnected from device', tag: 'DoorBluetoothService');
    } catch (e) {
      Logger.e('Error during disconnection', error: e.toString(), tag: 'DoorBluetoothService');
    }
  }

  void _updateDoorStatus(DoorStatus status) {
    _doorStatusController.add(status);
  }

  void dispose() {
    _doorStatusController.close();
    _connectionController.close();
    _notificationController.close();
    disconnect();
  }
}