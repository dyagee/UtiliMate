// lib/screens/time_tools_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart';

class TimeToolsCategoryScreen extends StatelessWidget {
  const TimeToolsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeTools = AppConstants.getTimeTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Time Tools',
        helpContentKey: 'TIME_TOOLS_CATEGORY', // Will add this help content
      ),
      body: ToolGrid(tools: timeTools, title: 'Available Time Tools'),
    );
  }
}
