// lib/screens/generic_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart'; // Ensure ToolItem is imported
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart'; // Ensure ToolGrid is imported

class GenericCategoryScreen extends StatelessWidget {
  final String title;
  final List<ToolItem> tools;
  final String categoryHelpContentKey;

  const GenericCategoryScreen({
    super.key,
    required this.title,
    required this.tools,
    required this.categoryHelpContentKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        helpContentKey: categoryHelpContentKey,
      ),
      body: ToolGrid(
        tools: tools,
        title: title, // Pass the category title to the ToolGrid for display
      ),
    );
  }
}
