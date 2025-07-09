import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/utils/pdf_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';

class PdfToolsScreen extends StatefulWidget {
  const PdfToolsScreen({super.key});

  @override
  State<PdfToolsScreen> createState() => _PdfToolsScreenState();
}

class _PdfToolsScreenState extends State<PdfToolsScreen> {
  bool _isLoading = false;

  // Function to show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Function to handle operations and show loading/dialogs
  Future<void> _handleOperation(
    Future<String?> Function() operation,
    String successMessage,
  ) async {
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
                  onConfirm: () => FileUtils.openFile(filePath),
                  confirmButtonText: 'Open File',
                  showCancelButton: true,
                  cancelButtonText: 'Share File',
                  onCancel: () => FileUtils.shareFile(filePath),
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

  // PDF Tools functions
  Future<String?> _convertImageToPdf() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      List<File> imageFiles = images.map((xfile) => File(xfile.path)).toList();
      return PdfUtils.convertImagesToPdf(imageFiles);
    }
    return null;
  }

  Future<String?> _mergePdfs() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      List<File> pdfFiles =
          result.files.map((platformFile) => File(platformFile.path!)).toList();
      if (pdfFiles.length < 2) {
        if (mounted) {
          _showSnackBar(
            'Please select at least two PDF files to merge.',
            isError: true,
          );
        }
        return null;
      }
      return PdfUtils.mergePdfs(pdfFiles);
    }
    return null;
  }

  Future<String?> _splitPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final File pdfFile = File(result.files.single.path!);

      // Show dialog for split options
      if (mounted) {
        return showDialog<String?>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Split PDF Options'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Split into Individual Pages',
                      onPressed: () {
                        Navigator.pop(context, 'individual');
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Split by Page Range',
                      onPressed: () {
                        Navigator.pop(context, 'range');
                      },
                    ),
                  ],
                ),
              ),
        ).then((option) async {
          if (option == 'individual') {
            return PdfUtils.splitPdfIntoIndividualPages(pdfFile);
          } else if (option == 'range') {
            // You would typically prompt for start/end pages here
            // For simplicity, let's assume a fixed range or prompt via a TextField
            // For this example, let's just split a fixed range (e.g., pages 2-3)
            // In a real app, you'd add text fields for user input.
            final TextEditingController startPageController =
                TextEditingController();
            final TextEditingController endPageController =
                TextEditingController();

            if (mounted) {
              return showDialog<String?>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Enter Page Range'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: startPageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Start Page',
                            ),
                          ),
                          TextField(
                            controller: endPageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'End Page',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final int? startPage = int.tryParse(
                              startPageController.text,
                            );
                            final int? endPage = int.tryParse(
                              endPageController.text,
                            );
                            if (startPage != null &&
                                endPage != null &&
                                startPage <= endPage) {
                              Navigator.pop(context, '$startPage-$endPage');
                            } else {
                              if (mounted) {
                                _showSnackBar(
                                  'Invalid page range.',
                                  isError: true,
                                );
                              }
                            }
                          },
                          child: const Text('Split'),
                        ),
                      ],
                    ),
              ).then((rangeInput) {
                if (rangeInput != null) {
                  final parts = rangeInput.split('-');
                  final int start = int.parse(parts[0]);
                  final int end = int.parse(parts[1]);
                  return PdfUtils.splitPdfByPageRange(pdfFile, start, end);
                }
                return null;
              });
            }
          }
          return null;
        });
      }
    }
    return null;
  }

  Future<String?> _compressPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final File pdfFile = File(result.files.single.path!);
      // Note: True PDF compression is complex and often requires server-side processing
      // or specialized libraries. This implementation will re-save the PDF which
      // might reduce size if images are re-encoded at a lower quality.
      return PdfUtils.compressPdf(pdfFile);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Tools')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolCard(
                  context,
                  icon: Icons.image,
                  title: 'Convert Image to PDF',
                  description:
                      'Combine multiple images into a single PDF document.',
                  onPressed:
                      () => _handleOperation(
                        _convertImageToPdf,
                        'Images converted to PDF successfully!',
                      ),
                ),
                _buildToolCard(
                  context,
                  icon: Icons.merge_type,
                  title: 'Merge PDFs',
                  description: 'Combine two or more PDF files into one.',
                  onPressed:
                      () => _handleOperation(
                        _mergePdfs,
                        'PDFs merged successfully!',
                      ),
                ),
                _buildToolCard(
                  context,
                  icon: Icons.call_split,
                  title: 'Split PDF',
                  description:
                      'Divide a PDF into individual pages or a custom range.',
                  onPressed:
                      () => _handleOperation(
                        _splitPdf,
                        'PDF split successfully!',
                      ),
                ),
                _buildToolCard(
                  context,
                  icon: Icons.compress,
                  title: 'Compress PDF',
                  description:
                      'Reduce the file size of your PDF documents (basic compression).',
                  onPressed:
                      () => _handleOperation(
                        _compressPdf,
                        'PDF compressed successfully!',
                      ),
                ),
                _buildToolCard(
                  context,
                  icon: Icons.description,
                  title: 'Convert Word to PDF (Coming Soon)',
                  description:
                      'Convert Word documents (.docx) to PDF format. (Requires backend service)',
                  onPressed: () {
                    _showSnackBar(
                      'This feature is not yet implemented and typically requires a backend service.',
                      isError: true,
                    );
                  },
                  isEnabled:
                      false, // Disable this button as it's not implemented client-side
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
    bool isEnabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isEnabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
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
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: CustomButton(
                    text: isEnabled ? 'Select File(s)' : 'Unavailable',
                    onPressed: isEnabled ? onPressed : null,
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
      ),
    );
  }
}
