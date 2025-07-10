// lib/utils/image_utils.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img; // Ensure this import is correct
import 'package:utilimate/utils/file_utils.dart'; // For saveFile

class ImageUtils {
  /// Resizes an image to the specified width and/or height.
  /// If only one dimension is provided, the aspect ratio is maintained.
  static Future<String?> resizeImage(
    File imageFile, {
    int? width,
    int? height,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print('Could not decode image: ${imageFile.path}');
        return null;
      }

      img.Image resizedImage;
      if (width != null && height != null) {
        resizedImage = img.copyResize(
          originalImage,
          width: width,
          height: height,
        );
      } else if (width != null) {
        resizedImage = img.copyResize(originalImage, width: width);
      } else if (height != null) {
        resizedImage = img.copyResize(originalImage, height: height);
      } else {
        print('No dimensions provided for resizing.');
        return null;
      }

      final String fileName =
          'resized_${DateTime.now().millisecondsSinceEpoch}.png';
      final Uint8List resizedBytes = Uint8List.fromList(
        img.encodePng(resizedImage),
      );
      return FileUtils.saveFile(resizedBytes, fileName);
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }

  /// Crops an image to the specified rectangle.
  /// x, y are the top-left coordinates of the crop rectangle.
  /// width, height are the dimensions of the crop rectangle.
  static Future<String?> cropImage(
    File imageFile, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print('Could not decode image: ${imageFile.path}');
        return null;
      }

      // Ensure crop dimensions are within image bounds
      if (x < 0 ||
          y < 0 ||
          x + width > originalImage.width ||
          y + height > originalImage.height) {
        print('Crop dimensions out of image bounds.');
        return null;
      }

      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final String fileName =
          'cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final Uint8List croppedBytes = Uint8List.fromList(
        img.encodePng(croppedImage),
      );
      return FileUtils.saveFile(croppedBytes, fileName);
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  /// Converts an image to a specified format (e.g., 'png', 'jpeg', 'webp').
  static Future<String?> convertImageFormat(
    File imageFile,
    String format,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print('Could not decode image: ${imageFile.path}');
        return null;
      }

      Uint8List convertedBytes;
      String newExtension;

      switch (format.toLowerCase()) {
        case 'png':
          convertedBytes = Uint8List.fromList(img.encodePng(originalImage));
          newExtension = 'png';
          break;
        case 'jpeg':
        case 'jpg':
          convertedBytes = Uint8List.fromList(img.encodeJpg(originalImage));
          newExtension = 'jpg';
          break;
        // Removed 'webp' case as it's read-only for encoding in the image package
        case 'gif':
          convertedBytes = Uint8List.fromList(img.encodeGif(originalImage));
          newExtension = 'gif';
          break;
        case 'bmp':
          convertedBytes = Uint8List.fromList(img.encodeBmp(originalImage));
          newExtension = 'bmp';
          break;
        case 'tiff':
          convertedBytes = Uint8List.fromList(img.encodeTiff(originalImage));
          newExtension = 'tiff';
          break;
        default:
          print('Unsupported format: $format');
          return null;
      }

      final String fileName =
          'converted_${DateTime.now().millisecondsSinceEpoch}.$newExtension';
      return FileUtils.saveFile(convertedBytes, fileName);
    } catch (e) {
      print('Error converting image format: $e');
      return null;
    }
  }
}
