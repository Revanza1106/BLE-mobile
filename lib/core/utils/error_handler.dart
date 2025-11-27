import '../utils/logger.dart';

enum AppErrorType {
  bluetoothPermissionDenied,
  bluetoothUnavailable,
  bluetoothConnectionFailed,
  bluetoothScanFailed,
  deviceNotFound,
  serialMismatch,
  invalidData,
  storageError,
  networkError,
  unknownError,
}

class AppError {
  final AppErrorType type;
  final String message;
  final String? details;
  final DateTime timestamp;

  const AppError({
    required this.type,
    required this.message,
    this.details,
    required this.timestamp,
  });

  factory AppError.bluetoothPermissionDenied({String? details}) {
    return AppError(
      type: AppErrorType.bluetoothPermissionDenied,
      message: 'Bluetooth permission is required to use this app',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.bluetoothUnavailable({String? details}) {
    return AppError(
      type: AppErrorType.bluetoothUnavailable,
      message: 'Bluetooth is not available or disabled',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.bluetoothConnectionFailed({String? details}) {
    return AppError(
      type: AppErrorType.bluetoothConnectionFailed,
      message: 'Failed to connect to Bluetooth device',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.bluetoothScanFailed({String? details}) {
    return AppError(
      type: AppErrorType.bluetoothScanFailed,
      message: 'Bluetooth scan failed',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.deviceNotFound({String? details}) {
    return AppError(
      type: AppErrorType.deviceNotFound,
      message: 'No compatible device found',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.serialMismatch({String? expected, String? actual}) {
    return AppError(
      type: AppErrorType.serialMismatch,
      message: 'Device serial number does not match saved serial',
      details: 'Expected: $expected, Actual: $actual',
      timestamp: DateTime.now(),
    );
  }

  factory AppError.invalidData({String? details}) {
    return AppError(
      type: AppErrorType.invalidData,
      message: 'Invalid data received',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.storageError({String? details}) {
    return AppError(
      type: AppErrorType.storageError,
      message: 'Failed to access local storage',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.unknownError({String? details}) {
    return AppError(
      type: AppErrorType.unknownError,
      message: 'An unknown error occurred',
      details: details,
      timestamp: DateTime.now(),
    );
  }

  String getUserFriendlyMessage() {
    switch (type) {
      case AppErrorType.bluetoothPermissionDenied:
        return 'Please grant Bluetooth permission in Settings';
      case AppErrorType.bluetoothUnavailable:
        return 'Please enable Bluetooth on your device';
      case AppErrorType.bluetoothConnectionFailed:
        return 'Failed to connect. Please try again';
      case AppErrorType.bluetoothScanFailed:
        return 'Scan failed. Please try again';
      case AppErrorType.deviceNotFound:
        return 'Make sure your door device is nearby and powered on';
      case AppErrorType.serialMismatch:
        return 'This device is not the one you saved in settings';
      case AppErrorType.invalidData:
        return 'Received invalid data. Please try again';
      case AppErrorType.storageError:
        return 'Failed to save/load settings';
      case AppErrorType.networkError:
        return 'Network error occurred';
      case AppErrorType.unknownError:
        return 'An unexpected error occurred. Please try again';
    }
  }

  @override
  String toString() {
    return 'AppError('
        'type: $type, '
        'message: $message, '
        'details: $details, '
        'timestamp: $timestamp)';
  }
}

class ErrorHandler {
  static void logError(AppError error, {String? tag}) {
    Logger.e(
      'Error: ${error.message}',
      error: '${error.type.name}: ${error.details ?? "No details"}',
      tag: tag ?? 'ErrorHandler',
    );
  }

  static void logException(
    Exception exception, {
    String? tag,
    String? context,
  }) {
    final error = AppError.unknownError(
      details: 'Exception: ${exception.runtimeType}\nContext: $context',
    );
    logError(error, tag: tag);
  }

  static AppError createFromException(
    Exception exception, {
    String? context,
    AppErrorType? defaultType,
  }) {
    final exceptionString = exception.toString().toLowerCase();

    if (exceptionString.contains('permission') || exceptionString.contains('denied')) {
      return AppError.bluetoothPermissionDenied(details: context);
    } else if (exceptionString.contains('bluetooth') && exceptionString.contains('unavailable')) {
      return AppError.bluetoothUnavailable(details: context);
    } else if (exceptionString.contains('connection') || exceptionString.contains('connect')) {
      return AppError.bluetoothConnectionFailed(details: context);
    } else if (exceptionString.contains('scan') || exceptionString.contains('scanning')) {
      return AppError.bluetoothScanFailed(details: context);
    } else if (exceptionString.contains('storage') || exceptionString.contains('shared')) {
      return AppError.storageError(details: context);
    } else {
      return AppError.unknownError(details: context);
    }
  }

  static AppError createFromError(Object error, {String? context}) {
    if (error is Exception) {
      return createFromException(error, context: context);
    } else if (error is AppError) {
      return error;
    } else {
      return AppError.unknownError(
        details: 'Error type: ${error.runtimeType}\nContext: $context\nMessage: $error',
      );
    }
  }
}