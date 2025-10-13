import 'package:flutter/material.dart';

class AppLoadingDialog {
  static bool _isVisible = false;

  static void show(BuildContext context, {String message = "Loading..."}) {
    if (_isVisible) return; // Prevent multiple dialogs
    _isVisible = true;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: theme.colorScheme.primary,
                      backgroundColor: isDark
                          ? Colors.white12
                          : Colors.grey.shade300,
                    ),
                  ),
                  Image.asset(
                    "assets/images/publishing.png",
                    width: 28,
                    height: 28,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ).whenComplete(() => _isVisible = false);
  }

  static void hide(BuildContext context) {
    if (_isVisible) {
      Navigator.of(context, rootNavigator: true).pop();
      _isVisible = false;
    }
  }
}
