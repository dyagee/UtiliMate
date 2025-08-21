// lib/widgets/message_box.dart
import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onOk;
  final bool isError;

  const MessageBox({
    super.key,
    required this.title,
    required this.message,
    this.onOk,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color:
              isError
                  ? Colors.red.shade700
                  : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(child: Text(message)),
      actions: <Widget>[
        TextButton(
          onPressed: onOk ?? () => Navigator.of(context).pop(),
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}
