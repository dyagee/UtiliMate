import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/utils/pdf_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/services/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  bool _isLoading = false;
  List<File> _selectedImages = [];

  // Holds the AdWidget for the banner ad
  AdWidget? _bannerAdWidget;

  @override
  void initState() {
    super.initState();

    // Get the banner ad widget using the singleton's method.
    _bannerAdWidget = AdManager().getBannerAdWidget();

    // Use a delayed future to force a rebuild after the ad has loaded.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _bannerAdWidget = AdManager().getBannerAdWidget();
        });
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xfile) => File(xfile.path)).toList();
      });
    } else {
      if (mounted) _showSnackBar('No images selected.', isError: true);
    }
  }

  Future<void> _convertImagesToPdf() async {
    if (_selectedImages.isEmpty) {
      _showSnackBar('Please select images first.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final String? filePath = await PdfUtils.convertImagesToPdf(
        _selectedImages,
      );
      if (filePath != null) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'Success!',
                  message:
                      'Images converted to PDF successfully!\nFile saved at: ${filePath.split('/').last}',
                  onConfirm: () => FileUtils.openFile(filePath, context),
                  confirmButtonText: 'Open File',
                  showCancelButton: true,
                  cancelButtonText: 'Share File',
                  onCancel: () => FileUtils.shareFile(filePath, context),
                ),
          );
          setState(() {
            _selectedImages = []; // Clear selected images after conversion
          });
        }
      } else {
        if (mounted) {
          _showSnackBar('PDF conversion cancelled or failed.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error converting images to PDF: ${e.toString()}',
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
    // Check if the banner ad is ready to be displayed
    final bool isBannerAdReady = _bannerAdWidget != null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image to PDF Converter',
        helpContentKey: 'IMAGE_TO_PDF',
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
                          Icons.photo_library,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select Images',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedImages.isEmpty
                              ? 'No images selected.'
                              : '${_selectedImages.length} image(s) selected.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Pick Images',
                          onPressed: _pickImages,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Convert to PDF',
                            onPressed: _convertImagesToPdf,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ],
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
      bottomNavigationBar:
          isBannerAdReady
              ? SizedBox(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                child: _bannerAdWidget!,
              )
              : null,
    );
  }
}
