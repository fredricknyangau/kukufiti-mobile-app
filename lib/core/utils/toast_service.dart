import 'package:flutter/material.dart';

class ToastService {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Theme.of(context).colorScheme.primary);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Theme.of(context).colorScheme.error);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, Theme.of(context).colorScheme.secondary);
  }

  static void _showToast(BuildContext context, String message, Color backgroundColor) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
