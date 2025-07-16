// lib/screens/image_tools_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/widgets/custom_app_bar.dart'; // For the AppBar

class ImageToolsCategoryScreen extends StatelessWidget {
  const ImageToolsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter AppConstants.allTools to get only Image related tools
    final imageTools = AppConstants.getImageTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image Tools',
        helpContentKey: 'IMAGE_TOOLS_CATEGORY', // Key for Image category help
      ),
      body: ToolGrid(
        tools: imageTools,
        title:
            'Available Image Tools', // Title specifically for this category screen
      ),
    );
  }
}
