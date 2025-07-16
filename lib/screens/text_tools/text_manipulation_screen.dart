// lib/screens/text_tools/text_manipulation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class TextManipulationScreen extends StatefulWidget {
  const TextManipulationScreen({super.key});

  @override
  State<TextManipulationScreen> createState() => _TextManipulationScreenState();
}

class _TextManipulationScreenState extends State<TextManipulationScreen> {
  final TextEditingController _textController = TextEditingController();
  String _processedText = '';
  int _wordCount = 0;
  int _charCount = 0;
  int _charCountNoSpaces = 0;
  int _sentenceCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateTextAnalysis);
  }

  void _updateTextAnalysis() {
    final String text = _textController.text;
    setState(() {
      _processedText = text;
      _wordCount = _countWords(text);
      _charCount = text.length;
      _charCountNoSpaces = text.replaceAll(' ', '').length;
      _sentenceCount = _countSentences(text);
    });
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  int _countSentences(String text) {
    if (text.trim().isEmpty) return 0;
    // Simple regex to count sentences ending with ., !, ? followed by whitespace or end of string
    return RegExp(r'[.!?]+\s*').allMatches(text).length;
  }

  void _reverseText() {
    setState(() {
      _processedText = _textController.text.split('').reversed.join();
    });
  }

  void _toUpperCase() {
    setState(() {
      _processedText = _textController.text.toUpperCase();
    });
  }

  void _toLowerCase() {
    setState(() {
      _processedText = _textController.text.toLowerCase();
    });
  }

  void _capitalizeWords() {
    if (_textController.text.isEmpty) {
      _processedText = '';
      return;
    }
    setState(() {
      _processedText = _textController.text
          .split(' ')
          .map(
            (word) =>
                word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                    : '',
          )
          .join(' ');
    });
  }

  void _removeExtraSpaces() {
    setState(() {
      _processedText =
          _textController.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    });
  }

  void _removeAllSpaces() {
    setState(() {
      _processedText = _textController.text.replaceAll(' ', '');
    });
  }

  void _copyToClipboard() {
    if (_processedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _processedText));
      _showSnackBar('Text copied to clipboard!');
    } else {
      _showSnackBar('No text to copy.', isError: true);
    }
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _processedText = '';
      _wordCount = 0;
      _charCount = 0;
      _charCountNoSpaces = 0;
      _sentenceCount = 0;
    });
    _showSnackBar('Text cleared.');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_updateTextAnalysis);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Text Manipulation',
        helpContentKey: 'TEXT_MANIPULATION',
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
                      Icons.input,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Input Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Enter your text here',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Words: $_wordCount | Chars (with spaces): $_charCount | Chars (no spaces): $_charCountNoSpaces | Sentences: $_sentenceCount',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                      Icons.transform,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Text Operations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        CustomButton(
                          text: 'Reverse Text',
                          onPressed: _reverseText,
                        ),
                        CustomButton(
                          text: 'Uppercase',
                          onPressed: _toUpperCase,
                        ),
                        CustomButton(
                          text: 'Lowercase',
                          onPressed: _toLowerCase,
                        ),
                        CustomButton(
                          text: 'Capitalize Words',
                          onPressed: _capitalizeWords,
                        ),
                        CustomButton(
                          text: 'Remove Extra Spaces',
                          onPressed: _removeExtraSpaces,
                        ),
                        CustomButton(
                          text: 'Remove All Spaces',
                          onPressed: _removeAllSpaces,
                        ),
                      ],
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
                      Icons.output,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Processed Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minHeight: 100),
                      child: SelectableText(
                        _processedText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: 'Copy',
                          onPressed: _copyToClipboard,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          text: 'Clear All',
                          onPressed: _clearText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ],
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
