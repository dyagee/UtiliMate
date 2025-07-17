// lib/screens/text_tools/find_replace_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class FindReplaceScreen extends StatefulWidget {
  const FindReplaceScreen({super.key});

  @override
  State<FindReplaceScreen> createState() => _FindReplaceScreenState();
}

class _FindReplaceScreenState extends State<FindReplaceScreen> {
  final TextEditingController _originalTextController = TextEditingController();
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  String _modifiedText = '';
  String? _errorMessage;

  void _performFindReplace() {
    setState(() {
      _errorMessage = null; // Clear previous errors
      _modifiedText = '';
    });

    final String originalText = _originalTextController.text;
    final String findText = _findController.text;
    final String replaceText = _replaceController.text;

    if (originalText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter some text to perform find and replace.';
      });
      return;
    }
    if (findText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter text to find.';
      });
      return;
    }

    try {
      // Using replaceAll for simplicity; for regex, use replaceAll(RegExp(findText), replaceText)
      final String result = originalText.replaceAll(findText, replaceText);
      setState(() {
        _modifiedText = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during replacement: ${e.toString()}';
      });
    }
  }

  void _copyToClipboard() {
    if (_modifiedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _modifiedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modified text copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No modified text to copy.')),
      );
    }
  }

  @override
  void dispose() {
    _originalTextController.dispose();
    _findController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Find and Replace',
        helpContentKey: 'FIND_REPLACE_TOOL', // Will add this to AppConstants
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.text_fields,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Original Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _originalTextController,
                      maxLines: 5,
                      minLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Enter text here',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.search,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Find and Replace',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _findController,
                      decoration: const InputDecoration(
                        labelText: 'Text to Find',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _replaceController,
                      decoration: const InputDecoration(
                        labelText: 'Replace With',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Perform Find & Replace',
                      onPressed: () => _performFindReplace(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Modified Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        _modifiedText.isEmpty && _errorMessage == null
                            ? 'Result will appear here after replacement.'
                            : _modifiedText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Copy to Clipboard',
                      onPressed:
                          _modifiedText.isEmpty
                              ? null
                              : () => _copyToClipboard(),
                      icon: Icons.copy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
