// lib/screens/color_tools_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart';

class ColorToolsCategoryScreen extends StatelessWidget {
  const ColorToolsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorTools = AppConstants.getColorTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Color Tools',
        helpContentKey: 'COLOR_TOOLS_CATEGORY',
      ),
      body: ToolGrid(tools: colorTools, title: 'Available Color Tools'),
    );
  }
}
