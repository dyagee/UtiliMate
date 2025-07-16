// lib/screens/image_tools/image_cropper_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Alias for image package
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class ImageCropperScreen extends StatefulWidget {
  const ImageCropperScreen({super.key});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  bool _isLoading = false;
  File? _selectedImage;
  final TextEditingController _xController = TextEditingController(text: '0');
  final TextEditingController _yController = TextEditingController(text: '0');
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
          _xController.text = '0';
          _yController.text = '0';
        });
      } else {
        if (mounted) _showSnackBar('Could not decode image.', isError: true);
      }
    } else {
      if (mounted) _showSnackBar('No image selected.', isError: true);
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first.', isError: true);
      return;
    }

    final int? x = int.tryParse(_xController.text);
    final int? y = int.tryParse(_yController.text);
    final int? width = int.tryParse(_widthController.text);
    final int? height = int.tryParse(_heightController.text);

    if (x == null ||
        y == null ||
        width == null ||
        height == null ||
        x < 0 ||
        y < 0 ||
        width <= 0 ||
        height <= 0) {
      _showSnackBar(
        'Please enter valid crop coordinates and dimensions.',
        isError: true,
      );
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

      // Ensure crop area is within image bounds
      if (x + width > originalImage.width ||
          y + height > originalImage.height) {
        if (mounted) {
          _showSnackBar(
            'Crop area extends beyond image boundaries.',
            isError: true,
          );
        }
        return;
      }

      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final String outputPath =
          '${(await FileUtils.getAppDirectory()).path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodePng(croppedImage));

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ConfirmationDialog(
                title: 'Success!',
                message:
                    'Image cropped successfully!\nFile saved at: ${outputPath.split('/').last}',
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
          _xController.text = '0';
          _yController.text = '0';
          _widthController.clear();
          _heightController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error cropping image: ${e.toString()}', isError: true);
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
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image Cropper',
        helpContentKey: 'IMAGE_CROPPER',
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
                            Icons.crop,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Crop Area (Pixels)',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter X, Y (top-left corner) and Width, Height for the crop area.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _xController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'X (Start)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _yController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Y (Start)',
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
                                  controller: _widthController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Width',
                                  ),
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Crop Image',
                            onPressed: _cropImage,
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
