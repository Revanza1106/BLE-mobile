import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/utils/logger.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/debug_helper.dart';
import 'views/home_view.dart';
import 'viewmodels/door_viewmodel.dart';
import 'core/constants/app_constants.dart';

void main() async {
  Logger.i('Starting Smart Door App', tag: 'App');
  DebugHelper.setDebugMode(true); // Set to false in production

  // Initialize app with error handling
  try {
    // Request permissions
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
    // Continue without permissions - app will handle permission errors gracefully
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
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DoorViewModel? _doorViewModel;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      DebugHelper.logMethodEntry('initializeApp');

      _doorViewModel = await DoorViewModel.create();

      if (_doorViewModel != null) { await _doorViewModel!.loadSettings(); }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        DebugHelper.logMethodExit('initializeApp', result: 'Success');
      }
    } catch (e) {
      final error = ErrorHandler.createFromError(e, context: 'HomeScreen initialization');
      ErrorHandler.logError(error, tag: 'HomeScreen');

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = error.getUserFriendlyMessage();
        });
      }
    }
  }

  @override
  void dispose() {
    DebugHelper.logMethodEntry('dispose');
    _doorViewModel?.dispose();
    DebugHelper.logMethodExit('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
              SizedBox(height: 16),
              Text(
                'Initializing Smart Door...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isInitializing = true;
                      _errorMessage = null;
                    });
                    _initializeApp();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HomeView(viewModel: _doorViewModel!);
  }
}