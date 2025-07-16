// lib/screens/image_tools/image_format_converter_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Alias for image package
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class ImageFormatConverterScreen extends StatefulWidget {
  const ImageFormatConverterScreen({super.key});

  @override
  State<ImageFormatConverterScreen> createState() =>
      _ImageFormatConverterScreenState();
}

class _ImageFormatConverterScreenState
    extends State<ImageFormatConverterScreen> {
  bool _isLoading = false;
  File? _selectedImage;
  String? _selectedFormat;
  final List<String> _formats = [
    'png',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'tiff',
  ]; // Supported by image package

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedFormat = null; // Reset format selection
      });
    } else {
      if (mounted) _showSnackBar('No image selected.', isError: true);
    }
  }

  Future<void> _convertImageFormat() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first.', isError: true);
      return;
    }
    if (_selectedFormat == null) {
      _showSnackBar('Please select a target format.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final img.Image? originalImage = img.decodeImage(
        _selectedImage!.readAsBytesSync(),
      );
      if (originalImage == null) {
        if (mounted) {
          _showSnackBar('Failed to decode original image.', isError: true);
        }
        return;
      }

      List<int>? encodedBytes;
      String outputExtension = _selectedFormat!;

      switch (_selectedFormat) {
        case 'png':
          encodedBytes = img.encodePng(originalImage);
          break;
        case 'jpeg':
          encodedBytes = img.encodeJpg(originalImage);
          break;
        case 'gif':
          encodedBytes = img.encodeGif(originalImage);
          break;
        case 'bmp':
          encodedBytes = img.encodeBmp(originalImage);
          break;
        case 'tiff':
          encodedBytes = img.encodeTiff(originalImage);
          break;
        default:
          if (mounted) {
            _showSnackBar('Unsupported format selected.', isError: true);
          }
          return;
      }

      final String outputPath =
          '${(await FileUtils.getAppDirectory()).path}/converted_image_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(encodedBytes);

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ConfirmationDialog(
                title: 'Success!',
                message:
                    'Image converted to $_selectedFormat successfully!\nFile saved at: ${outputPath.split('/').last}',
                onConfirm: () => FileUtils.openFile(outputPath, context),
                confirmButtonText: 'Open File',
                showCancelButton: true,
                cancelButtonText: 'Share File',
                onCancel: () => FileUtils.shareFile(outputPath, context),
              ),
        );
        setState(() {
          _selectedImage = null; // Clear selected image after operation
          _selectedFormat = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error converting image format: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image Format Converter',
        helpContentKey: 'IMAGE_FORMAT_CONVERTER',
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
                          Icons.image,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select Image',
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
                          text: 'Pick Image',
                          onPressed: _pickImage,
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
                if (_selectedImage != null)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.compare_arrows,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Convert To',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose the desired output image format.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedFormat,
                            decoration: const InputDecoration(
                              labelText: 'Output Format',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                _formats.map((String format) {
                                  return DropdownMenuItem<String>(
                                    value: format,
                                    child: Text(format.toUpperCase()),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFormat = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Convert Format',
                            onPressed: _convertImageFormat,
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
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
