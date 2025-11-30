import 'package:flutter/material.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../core/services/notification_service.dart';

class SettingsView extends StatefulWidget {
  final SettingsViewModel viewModel;
  final VoidCallback? onSaved;

  const SettingsView({
    super.key,
    required this.viewModel,
    this.onSaved,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      final viewModel = widget.viewModel;

      if (viewModel.errorMessage != null) {
        _notificationService.showError(context, viewModel.errorMessage!);
      }

      if (!viewModel.isSaving && !viewModel.isLoading) {
        if (viewModel.errorMessage == null) {
          widget.onSaved?.call();
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _onSavePressed() async {
    if (!widget.viewModel.validateInputs()) {
      return;
    }

    final success = await widget.viewModel.saveSettings();
    if (success) {
      _notificationService.showSuccess(context, "Settings saved successfully!");
    }
  }

  Future<void> _onDeletePressed() async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed) {
      await widget.viewModel.clearAllSettings();
      _notificationService.showInfo(context, "All settings cleared");
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await _notificationService.showConfirmDialog(
      context,
      title: "Delete All Settings",
      content: "Are you sure you want to delete all saved settings? This action cannot be undone.",
      confirmText: "Delete",
      cancelText: "Cancel",
      confirmButtonColor: Colors.red,
      cancelButtonColor: Colors.grey,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String label,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blueAccent,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF121212),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: viewModel.nameController,
                    labelText: "Name",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: viewModel.serialController,
                    labelText: "Serial Number",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: viewModel.secretController,
                    labelText: "Secret",
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          onPressed: _onSavePressed,
                          label: "SAVE",
                          isLoading: viewModel.isSaving,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildButton(
                          onPressed: _onDeletePressed,
                          label: "DELETE",
                          backgroundColor: Colors.red,
                          isLoading: viewModel.isLoading,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Settings Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<bool>(
                          future: viewModel.hasAllRequiredSettings(),
                          builder: (context, snapshot) {
                            final hasSettings = snapshot.data ?? false;
                            return Row(
                              children: [
                                Icon(
                                  hasSettings ? Icons.check_circle : Icons.warning,
                                  color: hasSettings ? Colors.green : Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasSettings
                                        ? "All settings configured"
                                        : "Missing required settings",
                                    style: TextStyle(
                                      color: hasSettings ? Colors.green : Colors.orange,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}