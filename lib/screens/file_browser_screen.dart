// lib/screens/file_browser_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart'; // For app-specific directories
import 'package:permission_handler/permission_handler.dart'; // For storage permissions
import 'package:android_path_provider/android_path_provider.dart'; // For Android public paths
import 'package:open_filex/open_filex.dart'; // To open files
import 'package:share_plus/share_plus.dart'; // Correct import for SharePlus
import 'dart:developer' as developer; // For logging

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = false;
  String? _permissionError; // To show permission related errors

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _permissionError = null; // Clear previous errors
    });

    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _permissionError =
                'Storage permission denied. Cannot access files.';
            _isLoading = false;
          });
        }
        developer.log('FileBrowser: Storage permission denied.');
        return;
      }

      List<Directory> directoriesToScan = [];

      // 1. App's private documents directory (for PDFs, etc., and iOS primary)
      final appDocDir = await getApplicationDocumentsDirectory();
      directoriesToScan.add(appDocDir);
      developer.log('Scanning App Documents Dir: ${appDocDir.path}');

      // 2. Android's public Downloads directory (FIX: Corrected API usage)
      if (Platform.isAndroid) {
        try {
          // FIX: Corrected to getter downloadsPath as per documentation
          final downloadsPath = await AndroidPathProvider.downloadsPath;
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            directoriesToScan.add(downloadsDir);
            developer.log(
              'Scanning Android Public Downloads Dir: ${downloadsDir.path}',
            );
          } else {
            // Optionally create if it doesn't exist, though system usually handles it
            await downloadsDir.create(recursive: true);
            directoriesToScan.add(downloadsDir);
            developer.log(
              'Created and scanning Android Public Downloads Dir: ${downloadsDir.path}',
            );
          }
        } catch (e) {
          developer.log('Error getting Android Downloads directory: $e');
          // Fallback or notify user if public downloads directory is inaccessible
          if (mounted) {
            _showSnackBar(
              'Could not access public downloads folder: ${e.toString()}',
              isError: true,
            );
          }
        }
      }

      List<FileSystemEntity> allFiles = [];
      for (var dir in directoriesToScan) {
        if (await dir.exists()) {
          // List files non-recursively for top-level, or recursively if needed for subfolders
          // Use whereType for cleaner filtering
          final List<File> dirFiles =
              dir.listSync(recursive: true).whereType<File>().toList();
          allFiles.addAll(dirFiles);
        }
      }

      // Sort files by last modified date, newest first
      allFiles.sort((a, b) {
        final statA = a.statSync();
        final statB = b.statSync();
        return statB.modified.compareTo(statA.modified); // Newest first
      });

      if (mounted) {
        setState(() {
          _files = allFiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading files: $e');
      if (mounted) {
        setState(() {
          _permissionError =
              'An error occurred while loading files: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openFile(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (mounted) {
        if (result.type != ResultType.done) {
          _showSnackBar(
            'Could not open file: ${result.message}',
            isError: true,
          );
        }
      }
    } catch (e) {
      developer.log('Error opening file: $e');
      if (mounted) {
        _showSnackBar('Error opening file: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _renameFile(FileSystemEntity file) async {
    final String oldFileName = file.path.split('/').last;
    String? extension =
        oldFileName.contains('.') ? oldFileName.split('.').last : null;
    String baseName =
        extension != null
            ? oldFileName.substring(0, oldFileName.lastIndexOf('.'))
            : oldFileName;

    TextEditingController nameController = TextEditingController(
      text: baseName,
    );

    String? newBaseName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter new file name',
              suffixText: extension != null ? '.$extension' : '',
            ),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null); // Return null on cancel
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                Navigator.of(dialogContext).pop(nameController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (newBaseName != null &&
        newBaseName.isNotEmpty &&
        newBaseName != baseName) {
      String newFileName = newBaseName;
      if (extension != null) {
        newFileName += '.$extension';
      }

      final String newPath = '${file.parent.path}/$newFileName';
      try {
        await file.rename(newPath);
        if (mounted) {
          _showSnackBar('File renamed to $newFileName');
        }
        _loadFiles(); // Reload files to show updated name
      } catch (e) {
        developer.log('Error renaming file: $e');
        if (mounted) {
          _showSnackBar(
            'Failed to rename file: ${e.toString()}',
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          title: 'Confirm Delete',
          message:
              'Are you sure you want to delete "${file.path.split('/').last}"?',
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          confirmButtonText: 'Delete',
          confirmButtonColor: Colors.red,
          onCancel: () => Navigator.of(dialogContext).pop(false),
          cancelButtonText: 'Cancel',
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await file.delete();
        if (mounted) {
          _showSnackBar('File "${file.path.split('/').last}" deleted.');
        }
        _loadFiles(); // Reload files after deletion
      } catch (e) {
        developer.log('Error deleting file: $e');
        if (mounted) {
          _showSnackBar(
            'Failed to delete file: ${e.toString()}',
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _shareFile(String path) async {
    try {
      // Correct SharePlus usage as per documentation
      final XFile file = XFile(path);
      await SharePlus.instance.share(
        ShareParams(files: [file], text: 'Sharing file from UtiliMate'),
      );
    } catch (e) {
      developer.log('Error sharing file: $e');
      if (mounted) {
        _showSnackBar('Failed to share file: ${e.toString()}', isError: true);
      }
    }
  }

  // Moved _getFileSize inside the state class
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
      developer.log('Error getting file size for $path: $e');
      return 'N/A';
    }
  }

  // Moved _getFileIcon inside the state class
  IconData _getFileIcon(String fileName) {
    final String lowerCaseFileName = fileName.toLowerCase();
    if (lowerCaseFileName.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (lowerCaseFileName.endsWith('.mp4') ||
        lowerCaseFileName.endsWith('.mov') ||
        lowerCaseFileName.endsWith('.avi') ||
        lowerCaseFileName.endsWith('.mkv') ||
        lowerCaseFileName.endsWith('.webm')) {
      return Icons.video_file;
    } else if (lowerCaseFileName.endsWith('.jpg') ||
        lowerCaseFileName.endsWith('.jpeg') ||
        lowerCaseFileName.endsWith('.png') ||
        lowerCaseFileName.endsWith('.gif') ||
        lowerCaseFileName.endsWith('.webp')) {
      return Icons.image;
    } else if (lowerCaseFileName.endsWith('.mp3') ||
        lowerCaseFileName.endsWith('.wav') ||
        lowerCaseFileName.endsWith('.aac') ||
        lowerCaseFileName.endsWith('.flac')) {
      return Icons.audio_file;
    } else if (lowerCaseFileName.endsWith('.doc') ||
        lowerCaseFileName.endsWith('.docx')) {
      return Icons.description; // Word document
    } else if (lowerCaseFileName.endsWith('.xls') ||
        lowerCaseFileName.endsWith('.xlsx')) {
      return Icons.table_chart; // Excel spreadsheet
    } else if (lowerCaseFileName.endsWith('.ppt') ||
        lowerCaseFileName.endsWith('.pptx')) {
      return Icons.slideshow; // PowerPoint presentation
    } else if (lowerCaseFileName.endsWith('.zip') ||
        lowerCaseFileName.endsWith('.rar') ||
        lowerCaseFileName.endsWith('.7z')) {
      return Icons.folder_zip; // Archive file
    } else if (lowerCaseFileName.endsWith('.txt')) {
      return Icons.text_snippet; // Text file
    }
    return Icons.insert_drive_file; // Default generic file icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Manager', // Displayed title
        helpContentKey: 'FILE_MANAGEMENT_TOOL', // Still use this help key
        showBackButton: false,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                child: LoadingIndicator(),
              ) // Use LoadingIndicator here
              : _permissionError != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_off,
                        size: 80,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _permissionError!,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => openAppSettings(), // Open app settings
                        icon: const Icon(Icons.settings),
                        label: const Text('Open App Settings'),
                      ),
                    ],
                  ),
                ),
              )
              : _files.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      // Replaced withOpacity with withAlpha
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No files found yet.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        // Replaced withOpacity with withAlpha
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generated files and downloads will appear here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        // Replaced withOpacity with withAlpha
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Refresh Files',
                      onPressed: _loadFiles,
                      icon: Icons.refresh,
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
                          _getFileIcon(fileName), // Use the new helper function
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
                              onPressed:
                                  () => _renameFile(
                                    file,
                                  ), // Pass FileSystemEntity
                              tooltip: 'Rename',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color:
                                    Theme.of(context)
                                        .colorScheme
                                        .primary, // Use primary color for share
                              ),
                              onPressed: () => _shareFile(file.path),
                              tooltip: 'Share',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed:
                                  () => _deleteFile(
                                    file,
                                  ), // Pass FileSystemEntity
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                        onTap: () => _openFile(file.path),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
      floatingActionButton:
          _files.isNotEmpty || _permissionError != null
              ? FloatingActionButton(
                onPressed: _loadFiles,
                child: const Icon(Icons.refresh),
              )
              : null, // Only show FAB if files exist or there's a permission error
    );
  }
}
