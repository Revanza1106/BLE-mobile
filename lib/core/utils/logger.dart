import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static const String _resetColor = '\x1B[0m';
  static const String _redColor = '\x1B[31m';
  static const String _yellowColor = '\x1B[33m';
  static const String _blueColor = '\x1B[34m';

  static void _log(LogLevel level, String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();
    final tagString = tag != null ? '[$tag] ' : '';

    String color;
    switch (level) {
      case LogLevel.debug:
        color = _blueColor;
        break;
      case LogLevel.warning:
        color = _yellowColor;
        break;
      case LogLevel.error:
        color = _redColor;
        break;
      default:
        color = _resetColor;
    }

    final logMessage = '$color[$timestamp] $levelString: $tagString$message$_resetColor';
    debugPrint(logMessage);
  }

  static void d(String message, {String? tag}) => _log(LogLevel.debug, message, tag: tag);
  static void i(String message, {String? tag}) => _log(LogLevel.info, message, tag: tag);
  static void w(String message, {String? tag}) => _log(LogLevel.warning, message, tag: tag);
  static void e(String message, {String? error, String? tag}) {
    if (error != null) {
      _log(LogLevel.error, '$message\nError: $error', tag: tag);
    } else {
      _log(LogLevel.error, message, tag: tag);
    }
  }
}