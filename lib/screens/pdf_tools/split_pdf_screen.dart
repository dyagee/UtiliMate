// lib/screens/pdf_tools/split_pdf_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/utils/pdf_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class SplitPdfScreen extends StatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  State<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends State<SplitPdfScreen> {
  bool _isLoading = false;
  File? _selectedPdf;
  final TextEditingController _startPageController = TextEditingController();
  final TextEditingController _endPageController = TextEditingController();

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
        _startPageController.clear();
        _endPageController.clear();
      });
    } else {
      if (mounted) _showSnackBar('No PDF file selected.', isError: true);
    }
  }

  Future<void> _splitPdfIntoIndividualPages() async {
    if (_selectedPdf == null) {
      _showSnackBar('Please select a PDF file first.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final List<String> filePaths = await PdfUtils.splitPdfIntoIndividualPages(
        _selectedPdf!,
      );
      if (filePaths.isNotEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'Success!',
                  message:
                      'PDF split into ${filePaths.length} individual pages.\nFiles saved in app directory.',
                  onConfirm: () {
                    // Optionally open the first file or show file browser
                    FileUtils.openFile(filePaths.first, context);
                  },
                  confirmButtonText: 'Open First File',
                  showCancelButton: true,
                  cancelButtonText: 'Done',
                  onCancel: () {
                    Navigator.pop(context); // Just close dialog
                  },
                ),
          );
          setState(() {
            _selectedPdf = null; // Clear selected PDF after operation
          });
        }
      } else {
        if (mounted) {
          _showSnackBar('PDF split cancelled or failed.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error splitting PDF: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _splitPdfByPageRange() async {
    if (_selectedPdf == null) {
      _showSnackBar('Please select a PDF file first.', isError: true);
      return;
    }

    final int? startPage = int.tryParse(_startPageController.text);
    final int? endPage = int.tryParse(_endPageController.text);

    if (startPage == null ||
        endPage == null ||
        startPage <= 0 ||
        endPage <= 0 ||
        startPage > endPage) {
      _showSnackBar(
        'Please enter a valid page range (e.g., Start: 1, End: 5).',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final String? filePath = await PdfUtils.splitPdfByPageRange(
        _selectedPdf!,
        startPage,
        endPage,
      );
      if (filePath != null) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'Success!',
                  message:
                      'PDF split by range successfully!\nFile saved at: ${filePath.split('/').last}',
                  onConfirm: () => FileUtils.openFile(filePath, context),
                  confirmButtonText: 'Open File',
                  showCancelButton: true,
                  cancelButtonText: 'Share File',
                  onCancel: () => FileUtils.shareFile(filePath, context),
                ),
          );
          setState(() {
            _selectedPdf = null; // Clear selected PDF after operation
            _startPageController.clear();
            _endPageController.clear();
          });
        }
      } else {
        if (mounted) {
          _showSnackBar('PDF split cancelled or failed.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error splitting PDF by range: ${e.toString()}',
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
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Split PDF',
        helpContentKey: 'SPLIT_PDF',
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
                          Icons.picture_as_pdf,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select PDF File',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedPdf == null
                              ? 'No PDF file selected.'
                              : 'Selected: ${_selectedPdf!.path.split('/').last}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Pick PDF File',
                          onPressed: _pickPdf,
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
                if (_selectedPdf != null) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.view_carousel,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Split into Individual Pages',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Each page of the PDF will be saved as a separate PDF file.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Split All Pages',
                            onPressed: _splitPdfIntoIndividualPages,
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
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.content_cut,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Split by Page Range',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Extract a specific range of pages into a new PDF file.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _startPageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Start Page',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _endPageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'End Page',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Split by Range',
                            onPressed: _splitPdfByPageRange,
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
              ],
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
