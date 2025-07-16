// lib/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String confirmButtonText;
  final Color? confirmButtonColor; // Added optional confirmButtonColor
  final bool showCancelButton;
  final String? cancelButtonText;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmButtonText = 'OK',
    this.confirmButtonColor, // Initialize the parameter
    this.showCancelButton = false,
    this.cancelButtonText = 'Cancel',
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
      actions: <Widget>[
        if (showCancelButton)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call(); // Call optional onCancel callback
            },
            child: Text(cancelButtonText!),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                confirmButtonColor ??
                Theme.of(context).colorScheme.primary, // Use provided color
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
