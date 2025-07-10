import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message; // Reverted from Widget content;
  final VoidCallback onConfirm;
  final String confirmButtonText;
  final VoidCallback? onCancel;
  final String? cancelButtonText;
  final bool showCancelButton;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message, // Reverted from required this.content,
    this.confirmButtonText = 'OK',
    this.onCancel,
    this.cancelButtonText,
    this.showCancelButton = false,
    required this.onConfirm, // Ensure onConfirm is required
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(message), // Use Text widget with String message
      ),
      actions: <Widget>[
        if (showCancelButton)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelButtonText ?? 'Cancel'),
          ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(); // Dismiss dialog after action
          },
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
