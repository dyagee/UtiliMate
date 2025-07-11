import 'dart:ui' as ui; // Import for ImageByteFormat
import 'dart:typed_data'; // New import for ByteData
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For RepaintBoundary
import 'package:qr_flutter/qr_flutter.dart';
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final TextEditingController _qrDataController = TextEditingController();
  String _generatedQrData = '';
  final GlobalKey _qrKey =
      GlobalKey(); // Key to capture QR code widget as image

  void _generateQrCode() {
    setState(() {
      _generatedQrData = _qrDataController.text.trim();
    });
    if (_generatedQrData.isEmpty) {
      _showSnackBar(
        'Please enter some data to generate QR code.',
        isError: true,
      );
    }
  }

  Future<void> _saveQrCode() async {
    if (_generatedQrData.isEmpty) {
      _showSnackBar('No QR code to save. Generate one first.', isError: true);
      return;
    }

    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(
        pixelRatio: 3.0,
      ); // High resolution
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null) {
        final List<int> pngBytes = byteData.buffer.asUint8List();
        final String fileName =
            'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
        final String? filePath = await FileUtils.saveFile(pngBytes, fileName);

        if (filePath != null && mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'QR Code Saved!',
                  message: 'QR Code saved to:\n${filePath.split('/').last}',
                  onConfirm: () => FileUtils.openFile(filePath, context),
                  confirmButtonText: 'Open Image',
                  showCancelButton: true,
                  cancelButtonText: 'Share Image',
                  onCancel: () => FileUtils.shareFile(filePath, context),
                ),
          );
        } else if (mounted) {
          _showSnackBar('Failed to save QR code.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saving QR code: ${e.toString()}', isError: true);
      }
    }
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
    _qrDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'QR Code Generator',
        helpContentKey: 'QR_GENERATOR',
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
                      'Enter Data for QR Code',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _qrDataController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Text, URL, etc.',
                        hintText: 'e.g., https://www.google.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Generate QR Code',
                      onPressed: _generateQrCode,
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
            if (_generatedQrData.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Generated QR Code:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: _generatedQrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          gapless: false,
                          backgroundColor: Colors.white,
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Save QR Code as Image',
                        onPressed: _saveQrCode,
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
          ],
        ),
      ),
    );
  }
}
