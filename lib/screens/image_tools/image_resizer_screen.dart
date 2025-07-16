// lib/screens/image_tools/image_resizer_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Alias for image package
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class ImageResizerScreen extends StatefulWidget {
  const ImageResizerScreen({super.key});

  @override
  State<ImageResizerScreen> createState() => _ImageResizerScreenState();
}

class _ImageResizerScreenState extends State<ImageResizerScreen> {
  bool _isLoading = false;
  File? _selectedImage;
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _originalWidth;
  double? _originalHeight;

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
      final File pickedFile = File(image.path);
      final img.Image? decodedImage = img.decodeImage(
        pickedFile.readAsBytesSync(),
      );
      if (decodedImage != null) {
        setState(() {
          _selectedImage = pickedFile;
          _originalWidth = decodedImage.width.toDouble();
          _originalHeight = decodedImage.height.toDouble();
          _widthController.text = _originalWidth!.round().toString();
          _heightController.text = _originalHeight!.round().toString();
        });
      } else {
        if (mounted) _showSnackBar('Could not decode image.', isError: true);
      }
    } else {
      if (mounted) _showSnackBar('No image selected.', isError: true);
    }
  }

  Future<void> _resizeImage() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first.', isError: true);
      return;
    }

    final int? newWidth = int.tryParse(_widthController.text);
    final int? newHeight = int.tryParse(_heightController.text);

    if (newWidth == null && newHeight == null) {
      _showSnackBar('Please enter a new width or height.', isError: true);
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

      img.Image resizedImage;
      if (newWidth != null && newHeight != null) {
        // Resize to specific dimensions
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
        );
      } else if (newWidth != null) {
        // Resize by width, maintaining aspect ratio
        resizedImage = img.copyResize(originalImage, width: newWidth);
      } else {
        // Resize by height, maintaining aspect ratio
        resizedImage = img.copyResize(originalImage, height: newHeight!);
      }

      final String outputPath =
          '${(await FileUtils.getAppDirectory()).path}/resized_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodePng(resizedImage));

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ConfirmationDialog(
                title: 'Success!',
                message:
                    'Image resized successfully!\nFile saved at: ${outputPath.split('/').last}',
                onConfirm: () => FileUtils.openFile(outputPath, context),
                confirmButtonText: 'Open File',
                showCancelButton: true,
                cancelButtonText: 'Share File',
                onCancel: () => FileUtils.shareFile(outputPath, context),
              ),
        );
        setState(() {
          _selectedImage = null; // Clear selected image after operation
          _originalWidth = null;
          _originalHeight = null;
          _widthController.clear();
          _heightController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error resizing image: ${e.toString()}', isError: true);
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
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image Resizer',
        helpContentKey: 'IMAGE_RESIZER',
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
                          Text(
                            'Original Size: ${_originalWidth?.round()}x${_originalHeight?.round()}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
                            Icons.aspect_ratio,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'New Dimensions',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter new width or height. Leave one blank to maintain aspect ratio.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _widthController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Width',
                                  ),
                                  onChanged: (value) {
                                    if (_originalWidth != null &&
                                        _originalHeight != null &&
                                        _widthController.text.isNotEmpty &&
                                        _heightController.text.isEmpty) {
                                      final double? newWidth = double.tryParse(
                                        value,
                                      );
                                      if (newWidth != null && newWidth > 0) {
                                        _heightController.text =
                                            ((newWidth / _originalWidth!) *
                                                    _originalHeight!)
                                                .round()
                                                .toString();
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Height',
                                  ),
                                  onChanged: (value) {
                                    if (_originalWidth != null &&
                                        _originalHeight != null &&
                                        _heightController.text.isNotEmpty &&
                                        _widthController.text.isEmpty) {
                                      final double? newHeight = double.tryParse(
                                        value,
                                      );
                                      if (newHeight != null && newHeight > 0) {
                                        _widthController.text =
                                            ((newHeight / _originalHeight!) *
                                                    _originalWidth!)
                                                .round()
                                                .toString();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Resize Image',
                            onPressed: _resizeImage,
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
