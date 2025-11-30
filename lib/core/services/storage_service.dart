import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<String> getAppName() async {
    try {
      return _preferences?.getString(AppConstants.nameKey) ?? AppConstants.defaultName;
    } catch (e) {
      Logger.e('Failed to get app name', error: e.toString(), tag: 'StorageService');
      return AppConstants.defaultName;
    }
  }

  Future<void> setAppName(String name) async {
    try {
      await _preferences?.setString(AppConstants.nameKey, name);
      Logger.i('App name saved: $name', tag: 'StorageService');
    } catch (e) {
      Logger.e('Failed to save app name', error: e.toString(), tag: 'StorageService');
    }
  }

  Future<String?> getSerialNumber() async {
    try {
      return _preferences?.getString(AppConstants.serialKey);
    } catch (e) {
      Logger.e('Failed to get serial number', error: e.toString(), tag: 'StorageService');
      return null;
    }
  }

  Future<void> setSerialNumber(String serial) async {
    try {
      await _preferences?.setString(AppConstants.serialKey, serial);
      Logger.i('Serial number saved', tag: 'StorageService');
    } catch (e) {
      Logger.e('Failed to save serial number', error: e.toString(), tag: 'StorageService');
    }
  }

  Future<String?> getSecret() async {
    try {
      return _preferences?.getString(AppConstants.secretKey);
    } catch (e) {
      Logger.e('Failed to get secret', error: e.toString(), tag: 'StorageService');
      return null;
    }
  }

  Future<void> setSecret(String secret) async {
    try {
      await _preferences?.setString(AppConstants.secretKey, secret);
      Logger.i('Secret saved', tag: 'StorageService');
    } catch (e) {
      Logger.e('Failed to save secret', error: e.toString(), tag: 'StorageService');
    }
  }

  Future<bool> hasAllRequiredSettings() async {
    try {
      final serial = await getSerialNumber();
      final secret = await getSecret();
      return serial != null && secret != null && serial.isNotEmpty && secret.isNotEmpty;
    } catch (e) {
      Logger.e('Failed to check required settings', error: e.toString(), tag: 'StorageService');
      return false;
    }
  }

  Future<void> clearAll() async {
    try {
      await _preferences?.clear();
      Logger.i('All storage cleared', tag: 'StorageService');
    } catch (e) {
      Logger.e('Failed to clear storage', error: e.toString(), tag: 'StorageService');
    }
  }

  Future<void> saveSettings({
    required String name,
    required String serial,
    required String secret,
  }) async {
    try {
      await Future.wait([
        setAppName(name),
        setSerialNumber(serial),
        setSecret(secret),
      ]);
      Logger.i('All settings saved successfully', tag: 'StorageService');
    } catch (e) {
      Logger.e('Failed to save settings', error: e.toString(), tag: 'StorageService');
    }
  }
}