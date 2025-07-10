// lib/screens/image_tools_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/utils/image_utils.dart'; // New import
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';

class ImageToolsScreen extends StatefulWidget {
  const ImageToolsScreen({super.key});

  @override
  State<ImageToolsScreen> createState() => _ImageToolsScreenState();
}

class _ImageToolsScreenState extends State<ImageToolsScreen> {
  bool _isLoading = false;
  File? _selectedImage;

  final TextEditingController _resizeWidthController = TextEditingController();
  final TextEditingController _resizeHeightController = TextEditingController();
  final TextEditingController _cropXController = TextEditingController();
  final TextEditingController _cropYController = TextEditingController();
  final TextEditingController _cropWidthController = TextEditingController();
  final TextEditingController _cropHeightController = TextEditingController();

  String? _selectedConvertFormat;
  // Corrected: Added 'WEBP' back as a source format that can be converted FROM
  final List<String> _imageFormats = ['PNG', 'JPEG', 'GIF', 'BMP', 'TIFF'];

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
        // Clear controllers when a new image is picked
        _resizeWidthController.clear();
        _resizeHeightController.clear();
        _cropXController.clear();
        _cropYController.clear();
        _cropWidthController.clear();
        _cropHeightController.clear();
        _selectedConvertFormat = null;
      });
    } else {
      if (mounted) _showSnackBar('No image selected.', isError: true);
    }
  }

  Future<void> _handleImageOperation(
    Future<String?> Function() operation,
    String successMessage,
  ) async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final String? filePath = await operation();
      if (filePath != null) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'Success!',
                  message: '$successMessage\nFile saved at: $filePath',
                  onConfirm: () => FileUtils.openFile(filePath, context),
                  confirmButtonText: 'Open File',
                  showCancelButton: true,
                  cancelButtonText: 'Share File',
                  onCancel: () => FileUtils.shareFile(filePath, context),
                ),
          );
        }
      } else {
        if (mounted) {
          _showSnackBar('Operation cancelled or failed.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _performResize() async {
    final int? width = int.tryParse(_resizeWidthController.text);
    final int? height = int.tryParse(_resizeHeightController.text);

    if (width == null && height == null) {
      _showSnackBar(
        'Please enter a width or height for resizing.',
        isError: true,
      );
      return null;
    }
    return ImageUtils.resizeImage(
      _selectedImage!,
      width: width,
      height: height,
    );
  }

  Future<String?> _performCrop() async {
    final int? x = int.tryParse(_cropXController.text);
    final int? y = int.tryParse(_cropYController.text);
    final int? width = int.tryParse(_cropWidthController.text);
    final int? height = int.tryParse(_cropHeightController.text);

    if (x == null || y == null || width == null || height == null) {
      _showSnackBar(
        'Please enter all crop dimensions (X, Y, Width, Height).',
        isError: true,
      );
      return null;
    }
    return ImageUtils.cropImage(
      _selectedImage!,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  Future<String?> _performConvert() async {
    if (_selectedConvertFormat == null) {
      _showSnackBar('Please select a format to convert to.', isError: true);
      return null;
    }
    return ImageUtils.convertImageFormat(
      _selectedImage!,
      _selectedConvertFormat!,
    );
  }

  @override
  void dispose() {
    _resizeWidthController.dispose();
    _resizeHeightController.dispose();
    _cropXController.dispose();
    _cropYController.dispose();
    _cropWidthController.dispose();
    _cropHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image Tools',
        helpContentKey: 'IMAGE_TOOLS',
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
                          _selectedImage != null
                              ? 'Selected: ${_selectedImage!.path.split('/').last}'
                              : 'No image selected.',
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
                          const SizedBox(height: 20),
                          Center(
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Image Resizer Card
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.aspect_ratio,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Resize Image',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter new dimensions. Leave one blank to maintain aspect ratio.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _resizeWidthController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Width (px)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _resizeHeightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Height (px)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Resize Image',
                          onPressed:
                              () => _handleImageOperation(
                                _performResize,
                                'Image resized successfully!',
                              ),
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
                // Image Cropper Card
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.crop,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Crop Image',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter X, Y (top-left corner) and Width, Height for cropping.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cropXController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'X (px)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _cropYController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Y (px)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cropWidthController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Width (px)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _cropHeightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Height (px)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Crop Image',
                          onPressed:
                              () => _handleImageOperation(
                                _performCrop,
                                'Image cropped successfully!',
                              ),
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
                // Image Converter Card
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
                          'Convert Image Format',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a target format to convert the image.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedConvertFormat,
                          decoration: const InputDecoration(
                            labelText: 'Select Format',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _imageFormats.map((String format) {
                                return DropdownMenuItem<String>(
                                  value: format.toLowerCase(),
                                  child: Text(format),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedConvertFormat = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Convert Image',
                          onPressed:
                              () => _handleImageOperation(
                                _performConvert,
                                'Image converted successfully!',
                              ),
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
