// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui'; // Needed for Offset and Size
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:utilimate/utils/file_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

class PdfUtils {
  /// Converts a list of image files to a single PDF document.
  static Future<String?> convertImagesToPdf(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return null;

    final pdf = pw.Document();
    int pagesAdded = 0;

    for (final imageFile in imageFiles) {
      try {
        final imageBytes = await imageFile.readAsBytes();
        final image = img.decodeImage(imageBytes);
        if (image == null) {
          print('Could not decode image: ${imageFile.path}');
          continue;
        }

        final pw.MemoryImage pdfImage = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
        pagesAdded++;
      } catch (e) {
        print('Error processing image ${imageFile.path}: $e');
      }
    }

    if (pagesAdded == 0) {
      print('No valid images processed for PDF creation.');
      return null;
    }

    final String fileName =
        'images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final Uint8List bytes = await pdf.save();
    return FileUtils.saveFile(bytes, fileName);
  }

  /// Merges multiple PDF files into a single PDF document.
  static Future<String?> mergePdfs(List<File> pdfFiles) async {
    if (pdfFiles.length < 2) return null;

    try {
      final sync_pdf.PdfDocument mergedDocument = sync_pdf.PdfDocument();

      for (final pdfFile in pdfFiles) {
        final pdfBytes = await pdfFile.readAsBytes();
        final sourceDocument = sync_pdf.PdfDocument(inputBytes: pdfBytes);

        for (int i = 0; i < sourceDocument.pages.count; i++) {
          final page = sourceDocument.pages[i];
          final template = page.createTemplate();
          final newPage = mergedDocument.pages.add();

          newPage.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            Size(newPage.getClientSize().width, newPage.getClientSize().height),
          );
        }

        sourceDocument.dispose();
      }

      final String fileName =
          'merged_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final List<int> bytes = await mergedDocument.save();
      mergedDocument.dispose();

      return FileUtils.saveFile(bytes, fileName);
    } catch (e) {
      print('Error merging PDFs: $e');
      return null;
    }
  }

  /// Splits a PDF file into individual pages.
  static Future<List<String>> splitPdfIntoIndividualPages(File pdfFile) async {
    try {
      final pdfBytes = await pdfFile.readAsBytes();
      final originalDoc = sync_pdf.PdfDocument(inputBytes: pdfBytes);
      final String baseFileName = pdfFile.path
          .split('/')
          .last
          .replaceAll('.pdf', '');
      // Removed: final Directory appDirectory = await FileUtils.getAppDirectory();
      List<String> savedPaths = [];

      for (int i = 0; i < originalDoc.pages.count; i++) {
        final newDoc = sync_pdf.PdfDocument();
        final originalPage = originalDoc.pages[i];
        final template = originalPage.createTemplate();
        final newPage = newDoc.pages.add();

        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          Size(newPage.getClientSize().width, newPage.getClientSize().height),
        );

        final List<int> pageBytes = await newDoc.save();
        final String fileName = '${baseFileName}_page_${i + 1}.pdf';
        final String? savedPath = await FileUtils.saveFile(pageBytes, fileName);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
        newDoc.dispose();
      }

      originalDoc.dispose();
      // Changed return message to return the list directly, as per signature
      return savedPaths;
    } catch (e) {
      print('Error splitting PDF: $e');
      return []; // Return empty list on error
    }
  }

  /// Splits a PDF file by a specified page range.
  static Future<String?> splitPdfByPageRange(
    File pdfFile,
    int startPage,
    int endPage,
  ) async {
    try {
      final pdfBytes = await pdfFile.readAsBytes();
      final originalDoc = sync_pdf.PdfDocument(inputBytes: pdfBytes);

      if (startPage < 1 ||
          endPage > originalDoc.pages.count ||
          startPage > endPage) {
        print(
          'Invalid page range: start=$startPage, end=$endPage, total=${originalDoc.pages.count}',
        );
        originalDoc.dispose();
        return null;
      }

      final newDoc = sync_pdf.PdfDocument();

      for (int i = startPage - 1; i < endPage; i++) {
        final originalPage = originalDoc.pages[i];
        final template = originalPage.createTemplate();
        final newPage = newDoc.pages.add();

        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          Size(newPage.getClientSize().width, newPage.getClientSize().height),
        );
      }

      final String fileName =
          '${pdfFile.path.split('/').last.replaceAll('.pdf', '')}_range_$startPage-$endPage.pdf';
      final List<int> bytes = await newDoc.save();

      newDoc.dispose();
      originalDoc.dispose();

      return FileUtils.saveFile(bytes, fileName);
    } catch (e) {
      print('Error splitting PDF by page range: $e');
      return null;
    }
  }

  /// Compresses a PDF file by re-saving it.
  static Future<String?> compressPdf(File pdfFile) async {
    try {
      final pdfBytes = await pdfFile.readAsBytes();
      final sync_pdf.PdfDocument document = sync_pdf.PdfDocument(
        inputBytes: pdfBytes,
      );

      final List<int> bytes = await document.save();
      final String fileName =
          '${pdfFile.path.split('/').last.replaceAll('.pdf', '')}_compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String? savedPath = await FileUtils.saveFile(bytes, fileName);

      document.dispose();
      return savedPath;
    } catch (e) {
      print('Error compressing PDF: $e');
      return null;
    }
  }
}
