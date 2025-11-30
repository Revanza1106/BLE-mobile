class AppConstants {
  static const String appName = 'Smart Door';

  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String controlUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String serialUuid = "a1b2c3d4-5678-90ab-cdef-1234567890ab";

  static const String nameKey = 'name';
  static const String serialKey = 'serial';
  static const String secretKey = 'secret';

  static const Duration scanTimeout = Duration(seconds: 6);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration doorOperationDuration = Duration(seconds: 3);

  static const String commandPrefix = "SECRET";
  static const String commandSeparator = "|";
  static const String releaseCommand = "RELEASE";
  static const String alwaysOnCommand = "ALWAYS_ON";
  static const String lockCommand = "LOCK";

  static const Duration pulseDuration = Duration(seconds: 1);

  static const String defaultName = "DOOR";
  static const String clickToOpenText = "Klik untuk buka 3 detik";
  static const String settingHintText = "Isi Setting";
}