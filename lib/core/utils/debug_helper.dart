import '../utils/logger.dart';

class DebugHelper {
  static bool _debugMode = true; 

  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
    Logger.d('Debug mode ${enabled ? "enabled" : "disabled"}', tag: 'DebugHelper');
  }

  static void assertDebugMode() {
    if (!_debugMode) {
      Logger.w('Debug operation attempted in release mode', tag: 'DebugHelper');
    }
  }

  static void logMethodEntry(String methodName, {Map<String, dynamic>? params}) {
    if (!_debugMode) return;

    final paramsStr = params != null && params.isNotEmpty
        ? ' | Params: ${params.toString()}'
        : '';
    Logger.d('→ Entering $methodName$paramsStr', tag: 'DebugHelper');
  }

  static void logMethodExit(String methodName, {dynamic result}) {
    if (!_debugMode) return;

    final resultStr = result != null ? ' | Result: $result' : '';
    Logger.d('← Exiting $methodName$resultStr', tag: 'DebugHelper');
  }

  static void logStateChange<T>(String propertyName, T oldValue, T newValue, {String? tag}) {
    if (!_debugMode) return;

    Logger.d(
      'State change: $propertyName changed from "$oldValue" to "$newValue"',
      tag: tag ?? 'StateChange',
    );
  }

  static void logAsyncOperation(
    String operationName,
    Future<void> Function() operation, {
    String? tag,
  }) async {
    if (!_debugMode) {
      await operation();
      return;
    }

    final stopwatch = Stopwatch()..start();
    Logger.d('⏱ Starting async operation: $operationName', tag: tag ?? 'AsyncOperation');

    try {
      await operation();
      stopwatch.stop();
      Logger.d(
        '✅ Async operation completed: $operationName (${stopwatch.elapsedMilliseconds}ms)',
        tag: tag ?? 'AsyncOperation',
      );
    } catch (e) {
      stopwatch.stop();
      Logger.e(
        '❌ Async operation failed: $operationName (${stopwatch.elapsedMilliseconds}ms)',
        error: e.toString(),
        tag: tag ?? 'AsyncOperation',
      );
      rethrow;
    }
  }

  static void logPerformanceMetric(
    String metricName,
    Duration duration, {
    String? tag,
    Map<String, dynamic>? metadata,
  }) {
    if (!_debugMode) return;

    final metadataStr = metadata != null && metadata.isNotEmpty
        ? ' | Metadata: ${metadata.toString()}'
        : '';
    Logger.d(
      '⏱ Performance: $metricName took ${duration.inMilliseconds}ms$metadataStr',
      tag: tag ?? 'Performance',
    );
  }

  static void logBluetoothEvent(String event, {Map<String, dynamic>? data}) {
    if (!_debugMode) return;

    final dataStr = data != null && data.isNotEmpty
        ? ' | Data: ${data.toString()}'
        : '';
    Logger.d('📡 Bluetooth: $event$dataStr', tag: 'Bluetooth');
  }

  static void logUserAction(String action, {Map<String, dynamic>? context}) {
    if (!_debugMode) return;

    final contextStr = context != null && context.isNotEmpty
        ? ' | Context: ${context.toString()}'
        : '';
    Logger.d('👤 User Action: $action$contextStr', tag: 'UserAction');
  }

  static void logDataValidation(
    String dataType,
    bool isValid, {
    String? reason,
    dynamic data,
  }) {
    if (!_debugMode) return;

    final dataStr = data != null ? ' | Data: $data' : '';
    final reasonStr = reason != null ? ' | Reason: $reason' : '';

    Logger.d(
      '🔍 Validation: $dataType is ${isValid ? "valid" : "invalid"}$reasonStr$dataStr',
      tag: 'Validation',
    );
  }

  static void dumpAppState(Map<String, dynamic> state, {String? tag}) {
    if (!_debugMode) return;

    Logger.d('📊 App State Dump:', tag: tag ?? 'AppState');
    state.forEach((key, value) {
      Logger.d('  $key: $value', tag: tag ?? 'AppState');
    });
  }

  static void printStackTrace({String? tag}) {
    if (!_debugMode) return;

    final stackTrace = StackTrace.current;
    final frames = stackTrace.toString().split('\n');

    Logger.d('📍 Stack Trace:', tag: tag ?? 'StackTrace');
    for (int i = 1; i < frames.length && i < 10; i++) {
      Logger.d('  ${frames[i].trim()}', tag: tag ?? 'StackTrace');
    }
  }

  static void checkMemoryUsage() {
    if (!_debugMode) return;

    Logger.d('🧠 Memory check requested', tag: 'Memory');
    printStackTrace(tag: 'Memory');
  }

  static void logNetworkRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? statusCode,
    dynamic response,
  }) {
    if (!_debugMode) return;

    Logger.d('🌐 Network: $method $url', tag: 'Network');

    if (headers != null) {
      Logger.d('  Headers: $headers', tag: 'Network');
    }

    if (body != null) {
      Logger.d('  Body: $body', tag: 'Network');
    }

    if (statusCode != null) {
      Logger.d('  Status: $statusCode', tag: 'Network');
    }

    if (response != null) {
      Logger.d('  Response: $response', tag: 'Network');
    }
  }

  static void createDebugReport(Map<String, dynamic> additionalInfo) {
    if (!_debugMode) return;

    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0', 
      'platform': 'Flutter', 
      ...additionalInfo,
    };

    Logger.d('📋 Debug Report:', tag: 'DebugReport');
    report.forEach((key, value) {
      Logger.d('  $key: $value', tag: 'DebugReport');
    });
  }
}