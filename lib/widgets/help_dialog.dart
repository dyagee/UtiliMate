// lib/widgets/help_dialog.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/simple_markdown_parser.dart'; // New import

class HelpDialog extends StatelessWidget {
  final String title;
  final String markdownContent; // This holds the raw Markdown string

  const HelpDialog({
    super.key,
    required this.title,
    required this.markdownContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
      content: SingleChildScrollView(
        // Use RichText with our custom parser
        child: RichText(
          text: TextSpan(
            children: SimpleMarkdownParser.parse(markdownContent, context),
            // Default style for the RichText. The parser will override for specific spans.
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got It!'),
        ),
      ],
    );
  }
}
