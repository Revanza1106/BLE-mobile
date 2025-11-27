import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/utils/logger.dart';

class SettingsViewModel extends ChangeNotifier {
  StorageService? _storageService;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController secretController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  SettingsViewModel();

  // Static factory for proper async initialization
  static Future<SettingsViewModel> create() async {
    try {
      final storageService = await StorageService.getInstance();

      final viewModel = SettingsViewModel._(storageService);
      await viewModel.loadSettings();

      return viewModel;
    } catch (e) {
      Logger.e('Failed to create SettingsViewModel', error: e.toString(), tag: 'SettingsViewModel');
      // Return a ViewModel with error state
      return SettingsViewModel._(null);
    }
  }

  // Private constructor
  SettingsViewModel._(this._storageService);

  Future<void> loadSettings() async {
    try {
      _setLoading(true);
      _clearError();

      if (_storageService == null) {
        Logger.w('StorageService not initialized yet', tag: 'SettingsViewModel');
        _setError('Storage not ready. Please try again.');
        return;
      }

      final name = await _storageService!.getAppName();
      final serial = await _storageService!.getSerialNumber();
      final secret = await _storageService!.getSecret();

      nameController.text = name;
      serialController.text = serial ?? '';
      secretController.text = secret ?? '';

      Logger.d('Settings loaded successfully', tag: 'SettingsViewModel');
    } catch (e) {
      final errorMsg = 'Failed to load settings: ${e.toString()}';
      Logger.e('Load settings failed', error: e.toString(), tag: 'SettingsViewModel');
      _setError(errorMsg);
    } finally {
      _setLoading(false);
    }
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> saveSettings() async {
    if (_isSaving) return false;

    try {
      _setSaving(true);
      _clearError();

      // Validate inputs
      final name = nameController.text.trim();
      final serial = serialController.text.trim();
      final secret = secretController.text.trim();

      if (name.isEmpty) {
        _setError('Name cannot be empty');
        return false;
      }

      if (serial.isEmpty) {
        _setError('Serial number cannot be empty');
        return false;
      }

      if (secret.isEmpty) {
        _setError('Secret cannot be empty');
        return false;
      }

      // Save settings
      if (_storageService != null) {
        await _storageService!.saveSettings(
          name: name,
          serial: serial,
          secret: secret,
        );
      } else {
        _setError('Storage service not available');
        return false;
      }

      Logger.d('Settings saved successfully', tag: 'SettingsViewModel');
      return true;
    } catch (e) {
      final errorMsg = 'Failed to save settings: ${e.toString()}';
      Logger.e('Save settings failed', error: e.toString(), tag: 'SettingsViewModel');
      _setError(errorMsg);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<void> clearAllSettings() async {
    try {
      _setLoading(true);
      _clearError();

      if (_storageService != null) {
        await _storageService!.clearAll();

        // Clear controllers
        nameController.clear();
        serialController.clear();
        secretController.clear();
      }

      Logger.d('All settings cleared', tag: 'SettingsViewModel');
    } catch (e) {
      final errorMsg = 'Failed to clear settings: ${e.toString()}';
      Logger.e('Clear settings failed', error: e.toString(), tag: 'SettingsViewModel');
      _setError(errorMsg);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> hasAllRequiredSettings() async {
    try {
      if (_storageService != null) {
        return await _storageService!.hasAllRequiredSettings();
      }
      return false;
    } catch (e) {
      Logger.e('Check settings failed', error: e.toString(), tag: 'SettingsViewModel');
      return false;
    }
  }

  bool validateInputs() {
    _clearError();

    final name = nameController.text.trim();
    final serial = serialController.text.trim();
    final secret = secretController.text.trim();

    if (name.isEmpty) {
      _setError('Name cannot be empty');
      return false;
    }

    if (serial.isEmpty) {
      _setError('Serial number cannot be empty');
      return false;
    }

    if (secret.isEmpty) {
      _setError('Secret cannot be empty');
      return false;
    }

    return true;
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setSaving(bool saving) {
    if (_isSaving != saving) {
      _isSaving = saving;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    Logger.d('Disposing SettingsViewModel', tag: 'SettingsViewModel');

    // Dispose controllers
    nameController.dispose();
    serialController.dispose();
    secretController.dispose();

    super.dispose();
  }
}