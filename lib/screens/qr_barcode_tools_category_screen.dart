import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/widgets/custom_app_bar.dart'; // For the AppBar

class QrBarcodeToolsCategoryScreen extends StatelessWidget {
  const QrBarcodeToolsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter AppConstants.allTools to get only QR & Barcode related tools
    final qrBarcodeTools = AppConstants.getQrBarcodeTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'QR & Barcode Tools',
        helpContentKey:
            'QR_BARCODE_TOOLS_CATEGORY', // Key for QR & Barcode category help
      ),
      body: ToolGrid(
        tools: qrBarcodeTools,
        title:
            'Available QR & Barcode Tools', // Title specifically for this category screen
      ),
    );
  }
}
