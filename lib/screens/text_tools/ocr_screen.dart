// lib/screens/text_tools/ocr_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // Ensure this is imported
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  bool _isLoading = false;
  String _extractedText = '';
  File? _selectedImage;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickImageAndExtractText() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      if (mounted) _showSnackBar('No image selected.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedImage = File(image.path);
      _extractedText = ''; // Clear previous text
    });

    try {
      // Corrected: Use TextRecognitionScript.latin
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final InputImage inputImage = InputImage.fromFile(File(image.path));
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      setState(() {
        _extractedText = recognizedText.text;
      });
      textRecognizer.close();
      if (mounted) _showSnackBar('Text extracted successfully!');
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error extracting text: ${e.toString()}', isError: true);
      }
      setState(() {
        _extractedText = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_extractedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText));
      _showSnackBar('Text copied to clipboard!');
    } else {
      _showSnackBar('No text to copy.', isError: true);
    }
  }

  void _clearText() {
    setState(() {
      _extractedText = '';
      _selectedImage = null;
    });
    _showSnackBar('Text and image cleared.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'OCR (Image to Text)',
        helpContentKey: 'OCR_TOOL',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                          Icons.image_search,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Extract Text from Image',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedImage == null
                              ? 'No image selected.'
                              : 'Selected: ${_selectedImage!.path.split('/').last}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Pick Image & Extract',
                          onPressed: _pickImageAndExtractText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        if (_selectedImage != null) ...[
                          const SizedBox(height: 16),
                          Image.file(
                            _selectedImage!,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_extractedText.isNotEmpty)
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
                            'Extracted Text',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                              _extractedText,
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
                                text: 'Clear',
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
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
