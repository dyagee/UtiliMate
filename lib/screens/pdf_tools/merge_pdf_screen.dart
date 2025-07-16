// lib/screens/pdf_tools/merge_pdf_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/utils/pdf_utils.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  bool _isLoading = false;
  List<File> _selectedPdfs = [];

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickPdfs() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPdfs =
            result.files
                .map((platformFile) => File(platformFile.path!))
                .toList();
      });
    } else {
      if (mounted) _showSnackBar('No PDF files selected.', isError: true);
    }
  }

  Future<void> _mergePdfs() async {
    if (_selectedPdfs.length < 2) {
      _showSnackBar(
        'Please select at least two PDF files to merge.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final String? filePath = await PdfUtils.mergePdfs(_selectedPdfs);
      if (filePath != null) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ConfirmationDialog(
                  title: 'Success!',
                  message:
                      'PDFs merged successfully!\nFile saved at: ${filePath.split('/').last}',
                  onConfirm: () => FileUtils.openFile(filePath, context),
                  confirmButtonText: 'Open File',
                  showCancelButton: true,
                  cancelButtonText: 'Share File',
                  onCancel: () => FileUtils.shareFile(filePath, context),
                ),
          );
          setState(() {
            _selectedPdfs = []; // Clear selected PDFs after merge
          });
        }
      } else {
        if (mounted) {
          _showSnackBar('PDF merge cancelled or failed.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error merging PDFs: ${e.toString()}', isError: true);
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
        title: 'Merge PDFs',
        helpContentKey: 'MERGE_PDF',
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
                          'Select PDF Files',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedPdfs.isEmpty
                              ? 'No PDF files selected.'
                              : '${_selectedPdfs.length} PDF(s) selected.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Pick PDF Files',
                          onPressed: _pickPdfs,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        if (_selectedPdfs.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Merge PDFs',
                            onPressed: _mergePdfs,
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
    );
  }
}
