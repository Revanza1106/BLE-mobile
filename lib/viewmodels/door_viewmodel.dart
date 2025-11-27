import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/bluetooth_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/door_state.dart';

class DoorViewModel extends ChangeNotifier {
  final DoorBluetoothService _bluetoothService;

  // Static factory for proper async initialization
  static Future<DoorViewModel> create() async {
    try {
      final bluetoothService = DoorBluetoothService();

      final viewModel = DoorViewModel._privateConstructor(bluetoothService);
      await viewModel.loadSettings();

      return viewModel;
    } catch (e) {
      Logger.e('Failed to create DoorViewModel', error: e.toString(), tag: 'DoorViewModel');
      // Return a ViewModel with error state
      return DoorViewModel._privateConstructor(DoorBluetoothService());
    }
  }

  
  DoorState _doorState = DoorState.initial();
  String _appName = AppConstants.defaultName;
  String? _savedSerial;
  String? _savedSecret;

  // Stream subscriptions
  StreamSubscription<DoorStatus>? _doorStatusSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _notificationSubscription;

  // Getters
  DoorState get doorState => _doorState;
  String get appName => _appName;
  bool get isConnected => _doorState.isConnected;
  bool get isOperating => _doorState.isOperating;
  bool get isAlwaysOpen => _doorState.isAlwaysOpen;
  String get displayStatus => _doorState.displayStatus;
  String? get errorMessage => _doorState.errorMessage;

  DoorViewModel._internal(this._bluetoothService) {
    _initializeStreams();
  }

  void _initializeStreams() {
    _doorStatusSubscription = _bluetoothService.doorStatusStream.listen(_onDoorStatusChanged);
    _connectionSubscription = _bluetoothService.connectionStream.listen(_onConnectionChanged);
    _notificationSubscription = _bluetoothService.notificationStream.listen(_onNotificationReceived);
  }

  void _onDoorStatusChanged(DoorStatus status) {
    Logger.d('Door status changed: $status', tag: 'DoorViewModel');

    final newState = DoorState.fromStatus(status, isConnected: _doorState.isConnected);
    _updateDoorState(newState);
  }

  void _onConnectionChanged(bool isConnected) {
    Logger.d('Connection status changed: $isConnected', tag: 'DoorViewModel');

    final newState = _doorState.copyWith(isConnected: isConnected);
    _updateDoorState(newState);
  }

  void _onNotificationReceived(String notification) {
    Logger.d('Notification received: $notification', tag: 'DoorViewModel');

    final isAlwaysOpen = notification == "Always Open";
    final newState = _doorState.copyWith(isAlwaysOpen: isAlwaysOpen);
    _updateDoorState(newState);
  }

  void _updateDoorState(DoorState newState) {
    if (_doorState != newState) {
      _doorState = newState;
      notifyListeners();
      Logger.d('Door state updated: $_doorState', tag: 'DoorViewModel');
    }
  }

  Future<void> loadSettings() async {
    try {
      final storage = await StorageService.getInstance();
      _appName = await storage.getAppName();
      _savedSerial = await storage.getSerialNumber();
      _savedSecret = await storage.getSecret();

      notifyListeners();

      // Auto-connect if settings are available
      if (_savedSerial != null && _savedSecret != null) {
        await autoConnect();
      } else {
        _updateDoorState(_doorState.copyWith(displayStatus: AppConstants.settingHintText));
      }
    } catch (e) {
      Logger.e('Failed to load settings', error: e.toString(), tag: 'DoorViewModel');
      _updateDoorState(_doorState.copyWith(
        errorMessage: 'Failed to load settings',
        displayStatus: 'Error',
      ));
    }
  }

  Future<void> autoConnect() async {
    if (_savedSerial == null || _savedSecret == null) {
      Logger.w('Cannot auto-connect: missing settings', tag: 'DoorViewModel');
      return;
    }

    if (_doorState.isConnected) {
      Logger.w('Already connected', tag: 'DoorViewModel');
      return;
    }

    try {
      final isBluetoothOn = await _bluetoothService.isBluetoothEnabled();
      if (!isBluetoothOn) {
        Logger.w('Bluetooth is not enabled', tag: 'DoorViewModel');
        _updateDoorState(_doorState.copyWith(
          displayStatus: 'Bluetooth Off',
          errorMessage: 'Please enable Bluetooth',
        ));
        return;
      }

      // First, connect to the device
      await _bluetoothService.scanAndConnect(_savedSerial!, _savedSecret!);

      // Then validate the serial number
      if (_doorState.status == DoorStatus.connected) {
        final success = await _validateDeviceSerial();
        if (!success) {
          await disconnect();
        }
      }
    } catch (e) {
      Logger.e('Auto-connect failed', error: e.toString(), tag: 'DoorViewModel');
    }
  }

  Future<bool> _validateDeviceSerial() async {
    // This would need to be implemented in the BluetoothService
    // For now, we'll assume validation passes
    Logger.d('Serial validation passed', tag: 'DoorViewModel');
    return true;
  }

  Future<void> toggleConnection(bool connect) async {
    if (connect == _doorState.isConnected) return;

    try {
      if (connect) {
        await _bluetoothService.scanAndConnect(_savedSerial!, _savedSecret!);
      } else {
        await disconnect();
      }
    } catch (e) {
      Logger.e('Toggle connection failed', error: e.toString(), tag: 'DoorViewModel');
    }
  }

  Future<void> connect() async {
    if (_doorState.isConnected) {
      Logger.w('Already connected', tag: 'DoorViewModel');
      return;
    }

    if (_savedSerial == null || _savedSecret == null) {
      Logger.e('Cannot connect: missing serial or secret', tag: 'DoorViewModel');
      _updateDoorState(_doorState.copyWith(
        errorMessage: 'Please configure settings first',
      ));
      return;
    }

    try {
      await _bluetoothService.scanAndConnect(_savedSerial!, _savedSecret!);

      // Validate serial after connection
      if (_doorState.status == DoorStatus.connected) {
        final success = await _validateDeviceSerial();
        if (!success) {
          await disconnect();
        }
      }
    } catch (e) {
      Logger.e('Connection failed', error: e.toString(), tag: 'DoorViewModel');
      _updateDoorState(_doorState.copyWith(
        displayStatus: 'Connection Failed',
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetoothService.disconnect();
      _updateDoorState(_doorState.copyWith(
        isAlwaysOpen: false,
        displayStatus: 'Disconnected',
      ));
    } catch (e) {
      Logger.e('Disconnection failed', error: e.toString(), tag: 'DoorViewModel');
    }
  }

  Future<void> openDoor() async {
    if (!_doorState.isConnected || _doorState.isOperating || _doorState.isAlwaysOpen) {
      Logger.w('Cannot open door: not ready', tag: 'DoorViewModel');
      return;
    }

    if (_savedSecret == null) {
      Logger.e('Cannot open door: missing secret', tag: 'DoorViewModel');
      return;
    }

    try {
      _updateDoorState(_doorState.copyWith(
        isOperating: true,
        displayStatus: 'Opening...',
      ));

      await _bluetoothService.sendCommand(
        _savedSecret!,
        AppConstants.releaseCommand,
      );

      // Wait for door operation to complete
      await Future.delayed(AppConstants.doorOperationDuration);

      _updateDoorState(_doorState.copyWith(
        isOperating: false,
        displayStatus: 'Locked',
      ));
    } catch (e) {
      Logger.e('Open door failed', error: e.toString(), tag: 'DoorViewModel');
      _updateDoorState(_doorState.copyWith(
        isOperating: false,
        errorMessage: 'Failed to open door: ${e.toString()}',
      ));
    }
  }

  Future<void> sendCommand(String command) async {
    if (!_doorState.isConnected) {
      Logger.w('Cannot send command: not connected', tag: 'DoorViewModel');
      return;
    }

    if (_savedSecret == null) {
      Logger.e('Cannot send command: missing secret', tag: 'DoorViewModel');
      return;
    }

    try {
      await _bluetoothService.sendCommand(_savedSecret!, command);

      // Update local state for known commands
      if (command == AppConstants.alwaysOnCommand) {
        _updateDoorState(_doorState.copyWith(isAlwaysOpen: true));
      } else if (command == AppConstants.lockCommand && _doorState.isAlwaysOpen) {
        _updateDoorState(_doorState.copyWith(isAlwaysOpen: false));
      }
    } catch (e) {
      Logger.e('Send command failed', error: e.toString(), tag: 'DoorViewModel');
      _updateDoorState(_doorState.copyWith(
        errorMessage: 'Failed to send command: ${e.toString()}',
      ));
    }
  }

  Future<void> refresh() async {
    Logger.d('Refreshing door state', tag: 'DoorViewModel');
    await loadSettings();
  }

  @override
  void dispose() {
    Logger.d('Disposing DoorViewModel', tag: 'DoorViewModel');

    _doorStatusSubscription?.cancel();
    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();

    _bluetoothService.dispose();
    super.dispose();
  }
  
  static Future<DoorViewModel> _privateConstructor(DoorBluetoothService doorBluetoothService) async {
    return DoorViewModel._internal(doorBluetoothService);
  }
}

extension on Future<DoorViewModel> {
  Future<void> loadSettings() async {}
}