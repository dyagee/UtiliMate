import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utilimate/utils/file_utils.dart'; // For openFile, renameFile, deleteFile
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> entities = directory.listSync(
        recursive: false,
        followLinks: false,
      );
      setState(() {
        _files =
            entities
                .whereType<File>()
                .toList() // Only show files, not directories
              ..sort(
                (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
              ); // Sort by last modified, newest first
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading files: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

  Future<void> _renameFile(File file) async {
    final TextEditingController renameController = TextEditingController(
      text: file.path.split('/').last,
    );
    final String originalFileName = file.path.split('/').last;

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename File'),
            content: TextField(
              controller: renameController,
              decoration: const InputDecoration(labelText: 'New File Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final String newFileName = renameController.text.trim();
                  if (newFileName.isEmpty || newFileName == originalFileName) {
                    _showSnackBar(
                      'Please enter a valid new name.',
                      isError: true,
                    );
                    return;
                  }
                  Navigator.pop(context); // Dismiss dialog first
                  setState(() {
                    _isLoading = true;
                  });
                  final String? renamedPath = await FileUtils.renameFile(
                    file.path,
                    newFileName,
                  );
                  if (renamedPath != null) {
                    _showSnackBar('File renamed to: $newFileName');
                    _loadFiles(); // Reload files to update the list
                  } else {
                    _showSnackBar('Failed to rename file.', isError: true);
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: const Text('Rename'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteFile(File file) async {
    return showDialog<void>(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Confirm Delete',
            message:
                'Are you sure you want to delete "${file.path.split('/').last}"?',
            onConfirm: () async {
              setState(() {
                _isLoading = true;
              });
              final bool deleted = await FileUtils.deleteFile(file.path);
              if (deleted) {
                _showSnackBar('File deleted successfully.');
                _loadFiles(); // Reload files to update the list
              } else {
                _showSnackBar('Failed to delete file.', isError: true);
              }
              setState(() {
                _isLoading = false;
              });
            },
            confirmButtonText: 'Delete',
            showCancelButton: true,
            cancelButtonText: 'Cancel',
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Management',
        helpContentKey: 'FILE_MANAGEMENT',
      ),
      body: Stack(
        children: [
          _files.isEmpty && !_isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No files generated yet.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(text: 'Refresh Files', onPressed: _loadFiles),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadFiles,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _files.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final file = _files[index] as File;
                    final fileName = file.path.split('/').last;
                    final fileExtension =
                        fileName.split('.').last.toLowerCase();
                    final fileSize = (file.lengthSync() / 1024).toStringAsFixed(
                      2,
                    ); // Size in KB

                    IconData fileIcon;
                    Color iconColor;
                    if (fileExtension == 'pdf') {
                      fileIcon = Icons.picture_as_pdf;
                      iconColor = Colors.red;
                    } else if ([
                      'png',
                      'jpg',
                      'jpeg',
                      'gif',
                      'bmp',
                      'tiff',
                      'webp',
                    ].contains(fileExtension)) {
                      fileIcon = Icons.image;
                      iconColor = Colors.blueAccent;
                    } else if (['txt', 'log'].contains(fileExtension)) {
                      fileIcon = Icons.text_snippet;
                      iconColor = Colors.grey;
                    } else {
                      fileIcon = Icons.insert_drive_file;
                      iconColor = Colors.purple;
                    }

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Icon(fileIcon, size: 40, color: iconColor),
                        title: Text(
                          fileName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Size: $fileSize KB\nLast Modified: ${file.lastModifiedSync().toLocal().toString().split('.')[0]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => FileUtils.openFile(file.path, context),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Rename',
                              onPressed: () => _renameFile(file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () => _deleteFile(file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadFiles,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
