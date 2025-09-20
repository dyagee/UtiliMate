// lib/screens/file_browser_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:utilimate/services/ad_manager.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
// import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = false;
  String? _permissionError;

  static const String _utilimateFileSuffix = '_utilimate';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    super.dispose();
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

  // Helper to get base name (without extension)
  String _getBaseName(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex > 0) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }

  // Helper to get extension (without dot)
  String? _getExtension(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex > 0) {
      return fileName.substring(dotIndex + 1);
    }
    return null;
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _permissionError = null;
    });

    try {
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

      if (Platform.isAndroid) {
        try {
          final downloadsPath = await AndroidPathProvider.downloadsPath;
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            directoriesToScan.add(downloadsDir);
            developer.log(
              'Scanning Android Public Downloads Dir: ${downloadsDir.path}',
            );
          } else {
            await downloadsDir.create(recursive: true);
            directoriesToScan.add(downloadsDir);
            developer.log(
              'Created and scanning Android Public Downloads Dir: ${downloadsDir.path}',
            );
          }
        } catch (e) {
          developer.log('Error getting Android Downloads directory: $e');
          if (mounted) {
            _showSnackBar(
              'Could not access public downloads folder: ${e.toString()}',
              isError: true,
            );
          }
        }
      } else if (Platform.isIOS) {
        final appDocDir = await getApplicationDocumentsDirectory();
        directoriesToScan.add(appDocDir);
        developer.log('Scanning iOS App Documents Dir: ${appDocDir.path}');
      }

      List<FileSystemEntity> allFiles = [];
      for (var dir in directoriesToScan) {
        if (await dir.exists()) {
          final List<File> dirFiles =
              dir.listSync(recursive: true).whereType<File>().toList();
          allFiles.addAll(dirFiles);
        }
      }

      final List<FileSystemEntity> utilimateFiles =
          allFiles.where((file) {
            final String fileName = file.path.split('/').last;
            String baseName = _getBaseName(fileName);
            return baseName.endsWith(_utilimateFileSuffix);
          }).toList();

      utilimateFiles.sort((a, b) {
        final statA = a.statSync();
        final statB = b.statSync();
        return statB.modified.compareTo(statA.modified);
      });

      if (mounted) {
        setState(() {
          _files = utilimateFiles;
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

  Future<String?> _showRenameDialog(
    String initialBaseName,
    String fullSuffixAndExtension,
  ) async {
    TextEditingController nameController = TextEditingController(
      text: initialBaseName,
    );

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter new file name',
              suffixText: fullSuffixAndExtension,
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
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop(nameController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFile(FileSystemEntity file) async {
    final String oldFileName = file.path.split('/').last;
    String currentBaseName = _getBaseName(oldFileName);
    String? currentExtension = _getExtension(oldFileName);

    if (currentBaseName.endsWith(_utilimateFileSuffix)) {
      currentBaseName = currentBaseName.substring(
        0,
        currentBaseName.length - _utilimateFileSuffix.length,
      );
    }

    String fullSuffixText =
        '$_utilimateFileSuffix${currentExtension != null ? '.$currentExtension' : ''}';
    String? newBaseNameResult = await _showRenameDialog(
      currentBaseName,
      fullSuffixText,
    );

    if (newBaseNameResult != null && newBaseNameResult.isNotEmpty) {
      String newBaseName = newBaseNameResult;

      if (newBaseName.endsWith(_utilimateFileSuffix)) {
        newBaseName = newBaseName.substring(
          0,
          newBaseName.length - _utilimateFileSuffix.length,
        );
      }
      newBaseName = '$newBaseName$_utilimateFileSuffix';

      String newFileName = newBaseName;
      if (currentExtension != null) {
        newFileName += '.$currentExtension';
      }

      if (newFileName == oldFileName) {
        if (mounted) {
          _showSnackBar('File name is the same.', isError: false);
        }
        return;
      }

      final String newPath = '${file.parent.path}/$newFileName';
      try {
        await file.rename(newPath);
        if (mounted) {
          _showSnackBar('File renamed to $newFileName');
        }
        _loadFiles();
      } catch (e) {
        developer.log('Error renaming file: $e');
        if (mounted) {
          _showSnackBar(
            'Failed to rename file: ${e.toString()}',
            isError: true,
          );
        }
      }
    } else {
      if (mounted) {
        _showSnackBar('Rename cancelled or new name is empty.', isError: false);
      }
    }
  }

  // Future<void> _deleteFile(FileSystemEntity file) async {
  //   developer.log('Attempting to delete file: ${file.path}');
  //   bool? confirmDelete = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       return ConfirmationDialog(
  //         title: 'Confirm Delete',
  //         message:
  //             'Are you sure you want to delete "${file.path.split('/').last}"?',
  //         onConfirm: () {
  //           // FIX: Added log to confirm button press
  //           developer.log('ConfirmationDialog: Confirm button pressed.');
  //           Navigator.of(dialogContext).pop(true);
  //         },
  //         confirmButtonText: 'Delete',
  //         confirmButtonColor: Colors.red,
  //         onCancel: () {
  //           // FIX: Added log to cancel button press
  //           developer.log('ConfirmationDialog: Cancel button pressed.');
  //           Navigator.of(dialogContext).pop(false);
  //         },
  //         cancelButtonText: 'Cancel',
  //       );
  //     },
  //   );

  //   // FIX: Log the exact value returned by showDialog
  //   developer.log('showDialog for deletion returned: $confirmDelete');

  //   if (confirmDelete == true) {
  //     developer.log('User confirmed deletion for: ${file.path}');
  //     try {
  //       if (await file.exists()) {
  //         await file.delete(recursive: true);
  //         developer.log('File deleted successfully: ${file.path}');
  //         if (mounted) {
  //           _showSnackBar('File "${file.path.split('/').last}" deleted.');
  //         }
  //         _loadFiles();
  //       } else {
  //         developer.log('File does not exist at path: ${file.path}');
  //         if (mounted) {
  //           _showSnackBar(
  //             'File "${file.path.split('/').last}" not found. It might have been moved or deleted externally.',
  //             isError: true,
  //           );
  //         }
  //       }
  //     } catch (e, stackTrace) {
  //       developer.log(
  //         'Error deleting file: $e',
  //         error: e,
  //         stackTrace: stackTrace,
  //       );
  //       if (mounted) {
  //         _showSnackBar(
  //           'Failed to delete file: ${e.toString()}. Please check app permissions or if the file is in use.',
  //           isError: true,
  //         );
  //       }
  //     }
  //   } else {
  //     developer.log(
  //       'File deletion cancelled by user. Returned value: $confirmDelete',
  //     );
  //   }
  // }

  Future<void> _shareFile(String path) async {
    try {
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
      return Icons.description;
    } else if (lowerCaseFileName.endsWith('.xls') ||
        lowerCaseFileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    } else if (lowerCaseFileName.endsWith('.ppt') ||
        lowerCaseFileName.endsWith('.pptx')) {
      return Icons.slideshow;
    } else if (lowerCaseFileName.endsWith('.zip') ||
        lowerCaseFileName.endsWith('.rar') ||
        lowerCaseFileName.endsWith('.7z')) {
      return Icons.folder_zip;
    } else if (lowerCaseFileName.endsWith('.txt')) {
      return Icons.text_snippet;
    }
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Use the new, peculiar method to get the dedicated banner ad.
    final AdWidget? bannerAdWidget = AdManager().getFileBrowserBannerAdWidget();
    final bool isBannerAdReady = bannerAdWidget != null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Manager',
        helpContentKey: 'FILE_MANAGEMENT_TOOL',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: LoadingIndicator())
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
                        onPressed: () => openAppSettings(),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No UtiliMate files found yet.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generated files and downloads from UtiliMate will appear here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

                    // Remove the UtiliMate suffix for display purposes
                    String displayName = _getBaseName(fileName);
                    if (displayName.endsWith(_utilimateFileSuffix)) {
                      displayName = displayName.substring(
                        0,
                        displayName.length - _utilimateFileSuffix.length,
                      );
                    }
                    String? displayExtension = _getExtension(fileName);
                    if (displayExtension != null) {
                      displayName += '.$displayExtension';
                    }

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
                          _getFileIcon(fileName),
                          color: Theme.of(context).colorScheme.secondary,
                          size: 36,
                        ),
                        title: Text(
                          displayName,
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
                              onPressed: () => _renameFile(file),
                              tooltip: 'Rename',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () => _shareFile(file.path),
                              tooltip: 'Share',
                            ),
                            // IconButton(
                            //   icon: Icon(
                            //     Icons.delete,
                            //     color: Theme.of(context).colorScheme.error,
                            //   ),
                            //   onPressed: () => _deleteFile(file),
                            //   tooltip: 'Delete',
                            // ),
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
      bottomNavigationBar:
          isBannerAdReady
              ? SizedBox(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                child: bannerAdWidget,
              )
              : null,
      floatingActionButton:
          _files.isNotEmpty || _permissionError != null || _isLoading
              ? FloatingActionButton(
                onPressed: _loadFiles,
                child: const Icon(Icons.refresh),
              )
              : null,
    );
  }
}
