// lib/screens/pdf_tools_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/widgets/custom_app_bar.dart'; // For the AppBar

class PdfToolsCategoryScreen extends StatelessWidget {
  const PdfToolsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter AppConstants.allTools to get only PDF related tools
    final pdfTools = AppConstants.getPdfTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'PDF Tools',
        helpContentKey: 'PDF_TOOLS_CATEGORY', // Key for PDF category help
      ),
      body: ToolGrid(
        tools: pdfTools,
        title:
            'Available PDF Tools', // Title specifically for this category screen
      ),
    );
  }
}
