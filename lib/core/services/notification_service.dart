import 'package:flutter/material.dart';
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? Colors.blueAccent,
          duration: duration,
        ),
      );
      Logger.d('Snackbar shown: $message', tag: 'NotificationService');
    } catch (e) {
      Logger.e('Failed to show snackbar', error: e.toString(), tag: 'NotificationService');
    }
  }

  void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  void showError(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.redAccent);
  }

  void showInfo(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.blueAccent);
  }

  void showWarning(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.orangeAccent);
  }

  Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText = "OK",
    String? cancelText = "Cancel",
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                  onCancel?.call();
                },
                child: Text(cancelText),
              ),
            if (confirmText != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                  onConfirm?.call();
                },
                child: Text(confirmText),
              ),
          ],
        ),
      );
      Logger.d('Dialog shown: $title', tag: 'NotificationService');
      return result ?? false;
    } catch (e) {
      Logger.e('Failed to show dialog', error: e.toString(), tag: 'NotificationService');
      return false;
    }
  }
}
