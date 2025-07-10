// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart'; // For BuildContext, Navigator, Rect
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utilimate/screens/pdf_viewer_screen.dart'; // Import the PDF viewer screen

class FileUtils {
  /// Requests storage permission if needed.
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+, granular media permissions are preferred
      // For simplicity and broader compatibility, we'll keep storage permission for now.
      // If targeting specific Android versions, consider READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO.
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    // On iOS, permissions are typically handled by the app's Info.plist
    // and specific access (e.g., photos for image picker) is requested by packages.
    return true;
  }

  /// Gets the app's documents directory. This is where persistent user-generated
  /// files should be stored for in-app management.
  static Future<String> getAppDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Saves a file to the application's documents directory for persistent storage.
  /// This is the location that the FileBrowserScreen will look into.
  static Future<String?> saveFile(List<int> bytes, String fileName) async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      print('Storage permission denied.');
      return null;
    }

    try {
      final dir =
          await getAppDocumentsPath(); // Corrected: Use app documents for persistence
      final filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('File saved to: $filePath');
      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  /// Opens a file using the system default application or in-app viewer for PDFs.
  static Future<void> openFile(String filePath, BuildContext context) async {
    if (filePath.isEmpty) {
      print('Invalid file path.');
      return;
    }

    try {
      final String fileExtension = filePath.split('.').last.toLowerCase();
      if (fileExtension == 'pdf') {
        // Open PDF in the in-app viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PdfViewerScreen(
                  filePath: filePath,
                  fileName: filePath.split('/').last,
                ),
          ),
        );
      } else {
        // Open other file types using the system's default application
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  /// Shares a file using ShareParams (share_plus v11+).
  /// This function uses XFile and SharePlus.instance.share, which is the recommended
  /// approach and handles sharePositionOrigin internally or via ShareParams.
  static Future<void> shareFile(
    String filePath,
    BuildContext context, {
    String? text,
  }) async {
    if (filePath.isEmpty || !File(filePath).existsSync()) {
      print('Invalid file to share: $filePath');
      return;
    }

    try {
      final params = ShareParams(
        text: text ?? 'Check out this file from UtiliMate!',
        files: [XFile(filePath)],
        // sharePositionOrigin is handled by ShareParams internally for XFiles
        // or can be explicitly set if needed for specific UI scenarios
        // e.g., sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('File shared successfully!');
      } else if (result.status == ShareResultStatus.dismissed) {
        print('User dismissed the share dialog.');
      } else {
        print('Share failed or was cancelled.');
      }
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  /// Renames a file.
  /// Returns the new file path if successful, null otherwise.
  static Future<String?> renameFile(
    String originalFilePath,
    String newFileName,
  ) async {
    try {
      final File originalFile = File(originalFilePath);
      final String directoryPath = originalFile.parent.path;
      final String newFilePath = '$directoryPath/$newFileName';
      final File newFile = await originalFile.rename(newFilePath);
      print('File renamed from $originalFilePath to $newFilePath');
      return newFile.path;
    } catch (e) {
      print('Error renaming file: $e');
      return null;
    }
  }

  /// Deletes a file.
  /// Returns true if successful, false otherwise.
  static Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
        return true;
      }
      print('File not found for deletion: $filePath');
      return false; // File did not exist
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Picks a single file.
  static Future<File?> pickSingleFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      final path = result?.files.single.path;
      return (path != null) ? File(path) : null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Picks multiple files.
  static Future<List<File>?> pickMultipleFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return null;

      return result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();
    } catch (e) {
      print('Error picking multiple files: $e');
      return null;
    }
  }
}
