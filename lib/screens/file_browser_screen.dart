// lib/screens/file_browser_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:utilimate/utils/file_utils.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart'; // Ensure CustomButton is imported

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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<FileSystemEntity> loadedFiles = await FileUtils.listFiles();
      // Sort files by last modified date, newest first
      loadedFiles.sort((a, b) {
        final DateTime modA = a.statSync().modified;
        final DateTime modB = b.statSync().modified;
        return modB.compareTo(modA); // Descending order (newest first)
      });
      setState(() {
        _files = loadedFiles;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading files: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _renameFile(String oldPath, String currentName) async {
    TextEditingController renameController = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename File'),
            content: TextField(
              controller: renameController,
              decoration: const InputDecoration(
                hintText: 'Enter new file name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final String newName = renameController.text.trim();
                  if (newName.isEmpty) {
                    if (mounted) {
                      _showSnackBar(
                        'File name cannot be empty.',
                        isError: true,
                      );
                    }
                    return;
                  }
                  Navigator.pop(context); // Close dialog
                  setState(() {
                    _isLoading = true;
                  });
                  final bool success = await FileUtils.renameFile(
                    oldPath,
                    newName,
                  );
                  if (success && mounted) {
                    _showSnackBar('File renamed successfully!');
                    await _loadFiles(); // Reload files to update the list
                  } else if (mounted) {
                    _showSnackBar('Failed to rename file.', isError: true);
                  }
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: const Text('Rename'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteFile(String filePath) async {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Confirm Delete',
            message: 'Are you sure you want to delete this file?',
            onConfirm: () async {
              Navigator.pop(context); // Close dialog
              setState(() {
                _isLoading = true;
              });
              final bool success = await FileUtils.deleteFile(filePath);
              if (success && mounted) {
                _showSnackBar('File deleted successfully!');
                await _loadFiles(); // Reload files to update the list
              } else if (mounted) {
                _showSnackBar('Failed to delete file.', isError: true);
              }
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            confirmButtonText: 'Delete',
            confirmButtonColor:
                Theme.of(
                  context,
                ).colorScheme.error, // Fixed: Use color from theme
            showCancelButton: true,
            cancelButtonText: 'Cancel',
          ),
    );
  }

  String _getFileSize(String path) {
    try {
      final file = File(path);
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Manager',
        helpContentKey: 'FILE_MANAGEMENT_TOOL',
      ),
      body: Stack(
        children: [
          _files.isEmpty && !_isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                    ), // Fixed withOpacity
                    const SizedBox(height: 16),
                    Text(
                      'No files generated yet.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(
                          (0.7 * 255).round(),
                        ), // Fixed withOpacity
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Refresh Files',
                      onPressed: _loadFiles,
                      icon: Icons.refresh, // Fixed: icon parameter now exists
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadFiles,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final String fileName = file.path.split('/').last;
                    final DateTime lastModified = file.statSync().modified;
                    final String formattedDate = DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(lastModified);
                    final String fileSize = _getFileSize(file.path);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Icon(
                          Icons.insert_drive_file,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 36,
                        ),
                        title: Text(
                          fileName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Modified: $formattedDate\nSize: $fileSize',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => _renameFile(file.path, fileName),
                              tooltip: 'Rename',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => _deleteFile(file.path),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                        onTap: () => FileUtils.openFile(file.path, context),
                      ),
                    );
                  },
                ),
              ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
      floatingActionButton:
          _files.isNotEmpty
              ? FloatingActionButton(
                onPressed: _loadFiles,
                child: const Icon(Icons.refresh),
              )
              : null,
    );
  }
}
