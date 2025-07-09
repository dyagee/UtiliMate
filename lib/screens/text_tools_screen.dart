import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/utils/text_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';

class TextToolsScreen extends StatefulWidget {
  const TextToolsScreen({super.key});

  @override
  State<TextToolsScreen> createState() => _TextToolsScreenState();
}

class _TextToolsScreenState extends State<TextToolsScreen> {
  bool _isLoading = false;
  String _ocrResult = '';
  String _generatedPassword = '';
  String _convertedText = '';
  final TextEditingController _textToConvertController =
      TextEditingController();

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _extractTextFromImage() async {
    setState(() {
      _isLoading = true;
      _ocrResult = '';
    });
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final String? text = await TextUtils.extractTextFromImage(
          File(image.path),
        );
        setState(() {
          _ocrResult = text ?? 'No text found.';
        });
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'OCR Result',
                  message:
                      _ocrResult.isNotEmpty
                          ? _ocrResult
                          : 'No text found in the image.',
                  onConfirm: () {
                    if (_ocrResult.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: _ocrResult));
                      _showSnackBar('Text copied to clipboard!');
                    }
                    Navigator.pop(context);
                  },
                  confirmButtonText: 'Copy Text',
                  showCancelButton: true,
                  cancelButtonText: 'Close',
                  onCancel: () => Navigator.pop(context),
                ),
          );
        }
      } else {
        if (mounted) _showSnackBar('No image selected.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error extracting text: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = TextUtils.generateSecurePassword();
    });
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => ConfirmationDialog(
              title: 'Generated Password',
              message: _generatedPassword,
              onConfirm: () {
                Clipboard.setData(ClipboardData(text: _generatedPassword));
                _showSnackBar('Password copied to clipboard!');
                Navigator.pop(context);
              },
              confirmButtonText: 'Copy Password',
              showCancelButton: true,
              cancelButtonText: 'Close',
              onCancel: () => Navigator.pop(context),
            ),
      );
    }
  }

  void _convertText(String type) {
    final String inputText = _textToConvertController.text;
    if (inputText.isEmpty) {
      _showSnackBar('Please enter text to convert.', isError: true);
      return;
    }

    String result = '';
    if (type == 'binary') {
      result = TextUtils.textToBinary(inputText);
    } else if (type == 'hexadecimal') {
      result = TextUtils.textToHexadecimal(inputText);
    }

    setState(() {
      _convertedText = result;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => ConfirmationDialog(
              title: 'Converted Text ($type)',
              message: _convertedText,
              onConfirm: () {
                Clipboard.setData(ClipboardData(text: _convertedText));
                _showSnackBar('Converted text copied to clipboard!');
                Navigator.pop(context);
              },
              confirmButtonText: 'Copy Text',
              showCancelButton: true,
              cancelButtonText: 'Close',
              onCancel: () => Navigator.pop(context),
            ),
      );
    }
  }

  @override
  void dispose() {
    _textToConvertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Tools')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolCard(
                  context,
                  icon: Icons.document_scanner,
                  title: 'Extract Text from Images (OCR)',
                  description:
                      'Use Optical Character Recognition to extract text from an image.',
                  onPressed: _extractTextFromImage,
                  buttonText: 'Select Image',
                ),
                _buildToolCard(
                  context,
                  icon: Icons.vpn_key,
                  title: 'Generate Secure Password',
                  description:
                      'Create a strong, random password for your accounts.',
                  onPressed: _generatePassword,
                  buttonText: 'Generate Password',
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.code,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Convert Text',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Convert text to binary or hexadecimal format.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _textToConvertController,
                          decoration: const InputDecoration(
                            labelText: 'Enter text here',
                            hintText: 'e.g., Hello World',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'To Binary',
                                onPressed: () => _convertText('binary'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                text: 'To Hexadecimal',
                                onPressed: () => _convertText('hexadecimal'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
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
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: CustomButton(
                  text: buttonText,
                  onPressed: onPressed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
