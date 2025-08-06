import 'package:flutter/material.dart';

class LogoutDialog {
  final BuildContext context;
  final VoidCallback onLogoutConfirmed;
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;

  LogoutDialog({
    required this.context,
    required this.onLogoutConfirmed,
    this.title = 'Logout',
    this.content = 'Are you sure you want to logout?',
    this.cancelText = 'Cancel',
    this.confirmText = 'Logout',
  });

  void show() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLogoutConfirmed();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
