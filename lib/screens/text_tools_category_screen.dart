// lib/screens/text_tools_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/widgets/custom_app_bar.dart'; // For the AppBar

class TextToolsCategoryScreen extends StatelessWidget {
  const TextToolsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter AppConstants.allTools to get only Text related tools
    final textTools = AppConstants.getTextTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Text Tools',
        helpContentKey: 'TEXT_TOOLS_CATEGORY', // Key for Text category help
      ),
      body: ToolGrid(
        tools: textTools,
        title:
            'Available Text Tools', // Title specifically for this category screen
      ),
    );
  }
}
