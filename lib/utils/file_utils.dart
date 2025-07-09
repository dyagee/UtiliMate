// ignore_for_file: avoid_print

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  /// Requests storage permission if needed.
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// Gets the app's documents directory.
  static Future<String> getAppDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Saves a file in the temporary directory for sharing.
  static Future<String?> saveFile(List<int> bytes, String fileName) async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      print('Storage permission denied.');
      return null;
    }

    try {
      final dir = await getTemporaryDirectory(); // Better for sharing
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('File saved to: $filePath');
      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  /// Opens a file using the system default application.
  static Future<void> openFile(String filePath) async {
    if (filePath.isEmpty) {
      print('Invalid file path.');
      return;
    }

    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  /// Shares a file using ShareParams (share_plus v11+).
  static Future<void> shareFile(String filePath, {String? text}) async {
    if (filePath.isEmpty || !File(filePath).existsSync()) {
      print('Invalid file to share.');
      return;
    }

    try {
      final params = ShareParams(
        text: text ?? 'Check out this file!',
        files: [XFile(filePath)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing!');
      } else if (result.status == ShareResultStatus.dismissed) {
        print('User dismissed the share dialog.');
      }
    } catch (e) {
      print('Error sharing file: $e');
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
