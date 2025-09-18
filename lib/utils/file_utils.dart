// lib/utils/file_utils.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'dart:developer' as developer; // For logging

class FileUtils {
  static const String _utilimateFileSuffix = '_utilimate';

  /// Returns the public downloads directory where generated files will be stored.
  /// Creates the directory if it doesn't exist.
  static Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        developer.log('Permission denied to access storage.');
        return null;
      }
      final Directory downloadDir = Directory(
        await AndroidPathProvider.downloadsPath,
      );
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } else if (Platform.isIOS) {
      // For iOS, save to a dedicated folder within the app's documents directory
      // as there's no public 'Downloads' folder.
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory utilimateDir = Directory(
        '${appDocDir.path}/UtiliMateDownloads',
      );
      if (!await utilimateDir.exists()) {
        await utilimateDir.create(recursive: true);
      }
      return utilimateDir;
    }
    return null;
  }

  /// Saves bytes to a file within the app's dedicated directory.
  /// Returns the full path of the saved file, or null if saving fails.
  static Future<String?> saveFile(List<int> bytes, String fileName) async {
    try {
      final Directory? downloadDir = await getDownloadDirectory();
      if (downloadDir == null) {
        return null;
      }

      String baseName = fileName;
      String extension = '';
      final int dotIndex = fileName.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex > 0) {
        baseName = fileName.substring(0, dotIndex);
        extension = fileName.substring(dotIndex);
      }

      // Append the suffix to the base name
      String newFileName = '$baseName$_utilimateFileSuffix$extension';

      int counter = 1;
      String finalFileName = newFileName;
      String filePath = '${downloadDir.path}/$finalFileName';

      // Ensure the file name is unique
      while (await File(filePath).exists()) {
        finalFileName =
            '$baseName (${counter++})$_utilimateFileSuffix$extension';
        filePath = '${downloadDir.path}/$finalFileName';
      }

      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      developer.log('File saved to: ${file.path}');
      return file.path;
    } catch (e) {
      developer.log('Error saving file: $e');
      return null;
    }
  }

  /// Lists all files within the app's dedicated directory.
  /// NOTE: This function's utility is now limited to iOS due to Android's
  /// scoped storage.
  static Future<List<FileSystemEntity>> listFiles() async {
    try {
      final Directory? dir = await getDownloadDirectory();
      if (dir == null) {
        return [];
      }
      return dir.listSync(recursive: false).toList();
    } catch (e) {
      developer.log('Error listing files: $e');
      return [];
    }
  }

  /// Opens a file using the device's default application.
  static Future<void> openFile(String filePath, BuildContext context) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      }
    } catch (e) {
      developer.log('Error opening file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
      }
    }
  }

  /// Renames a file.
  static Future<bool> renameFile(String oldPath, String newName) async {
    try {
      final File oldFile = File(oldPath);
      final Directory parentDir = oldFile.parent;
      final String newPath = '${parentDir.path}/$newName';
      await oldFile.rename(newPath);
      developer.log('File renamed from $oldPath to $newPath');
      return true;
    } catch (e) {
      developer.log('Error renaming file: $e');
      return false;
    }
  }

  /// Deletes a file.
  static Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        developer.log('File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error deleting file: $e');
      return false;
    }
  }

  /// Shares a file using the device's share sheet.
  static Future<void> shareFile(String filePath, BuildContext context) async {
    try {
      final XFile fileToShare = XFile(filePath); // Create XFile object
      await SharePlus.instance.share(
        ShareParams(
          files: [fileToShare],
          text: 'Check out this file from UtiliMate!', // Optional text
        ),
      );
    } catch (e) {
      developer.log('Error sharing file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing file: $e')));
      }
    }
  }
}
