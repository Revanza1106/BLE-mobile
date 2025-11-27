import 'package:flutter/material.dart';
import '../viewmodels/door_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../core/services/bluetooth_service.dart';
import '../core/constants/app_constants.dart';
import '../core/services/notification_service.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  final DoorViewModel viewModel;

  const HomeView({
    super.key,
    required this.viewModel,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppConstants.pulseDuration,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for state changes
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      final doorState = widget.viewModel.doorState;

      // Handle animation based on operating state
      if (doorState.isOperating) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }

      // Show error messages
      if (doorState.errorMessage != null) {
        _notificationService.showError(context, doorState.errorMessage!);
      }

      // Show success messages
      if (doorState.status == DoorStatus.connected) {
        _notificationService.showSuccess(context, "Connected!");
      }
    }
  }

  void _onDoorTap() {
    widget.viewModel.openDoor();
  }

  void _onConnectionToggle(bool value) {
    widget.viewModel.toggleConnection(value);
    if (!value) {
      _notificationService.showInfo(context, "Disconnected");
    }
  }

  void _onAlwaysOpenPressed() {
    widget.viewModel.sendCommand(AppConstants.alwaysOnCommand);
  }

  void _onReleasePressed() {
    widget.viewModel.sendCommand(AppConstants.lockCommand);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.viewModel.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          Switch(
            value: widget.viewModel.isConnected,
            onChanged: _onConnectionToggle,
            activeThumbColor: Colors.green,
            inactiveThumbColor: Colors.grey,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _onDoorTap,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final doorState = widget.viewModel.doorState;
                    final isRed = doorState.displayStatus == "Open" || doorState.isOperating;
                    final primaryColor = isRed ? Colors.red : Colors.blue;

                    return Transform.scale(
                      scale: doorState.isOperating ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              doorState.displayStatus == "Open" || doorState.isOperating
                                  ? Icons.lock_open
                                  : Icons.lock,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              doorState.isOperating
                                  ? "Opening..."
                                  : doorState.displayStatus,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.clickToOpenText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 60),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: (widget.viewModel.isConnected && !widget.viewModel.isAlwaysOpen)
                        ? _onAlwaysOpenPressed
                        : null,
                    icon: const Icon(Icons.power_settings_new, size: 20),
                    label: const Text("Always Open"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: (widget.viewModel.isConnected && widget.viewModel.isAlwaysOpen)
                        ? _onReleasePressed
                        : null,
                    icon: const Icon(Icons.restore, size: 20),
                    label: const Text("Release"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Settings Button
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final settingsViewModel = await SettingsViewModel.create();

                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsView(
                          viewModel: settingsViewModel,
                          onSaved: () => widget.viewModel.refresh(),
                        ),
                      ),
                    );

                    if (result == true) {
                      widget.viewModel.refresh();
                    }
                  } catch (e) {
                    _notificationService.showError(context, "Failed to open settings: ${e.toString()}");
                  }
                },
                icon: const Icon(Icons.settings, color: Colors.white70),
                label: const Text(
                  "Setting",
                  style: TextStyle(color: Colors.white70),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

