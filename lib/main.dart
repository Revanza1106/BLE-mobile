import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/utils/logger.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/debug_helper.dart';
import 'views/home_screen.dart';
import 'core/constants/app_constants.dart';

void main() async {
  Logger.i('Starting Smart Door App', tag: 'App');
  DebugHelper.setDebugMode(true); 

  try {
    await _requestPermissions();

    Logger.i('App initialized successfully', tag: 'App');
  } catch (e) {
    final error = ErrorHandler.createFromError(e, context: 'App initialization');
    ErrorHandler.logError(error, tag: 'App');
  }

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  try {
    Logger.d('Requesting app permissions', tag: 'Permissions');

    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    final statuses = await permissions.request();

    for (final permission in permissions) {
      if (statuses[permission] == PermissionStatus.denied ||
          statuses[permission] == PermissionStatus.permanentlyDenied) {
        Logger.w('Permission denied: ${permission.toString()}', tag: 'Permissions');
      }
    }

    Logger.d('Permissions requested successfully', tag: 'Permissions');
  } catch (e) {
    Logger.e('Failed to request permissions', error: e.toString(), tag: 'Permissions');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}