// lib/utils/file_utils.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart'; // Ensure this is imported

class FileUtils {
  /// Returns the application's documents directory where generated files will be stored.
  /// Creates the directory if it doesn't exist.
  static Future<Directory> getAppDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory utilimateDir = Directory('${appDocDir.path}/UtiliMate');
    if (!await utilimateDir.exists()) {
      await utilimateDir.create(recursive: true);
    }
    return utilimateDir;
  }

  /// Saves bytes to a file within the app's dedicated directory.
  /// Returns the full path of the saved file, or null if saving fails.
  static Future<String?> saveFile(List<int> bytes, String fileName) async {
    try {
      final Directory appDir = await getAppDirectory();
      final File file = File('${appDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      print('File saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  /// Lists all files within the app's dedicated directory.
  static Future<List<FileSystemEntity>> listFiles() async {
    try {
      final Directory appDir = await getAppDirectory();
      return appDir.listSync(recursive: false).toList();
    } catch (e) {
      print('Error listing files: $e');
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
      print('Error opening file: $e');
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
      print('File renamed from $oldPath to $newPath');
      return true;
    } catch (e) {
      print('Error renaming file: $e');
      return false;
    }
  }

  /// Deletes a file.
  static Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
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
      print('Error sharing file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing file: $e')));
      }
    }
  }
}
