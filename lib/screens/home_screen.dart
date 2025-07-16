// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/widgets/custom_app_bar.dart'; // For the AppBar

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All Tools',
        helpContentKey: 'ALL_TOOLS_CATEGORY', // New help key for All Tools
      ),
      body: ToolGrid(
        tools: AppConstants.allTools, // Display all tools
        title: 'Browse All Utilities', // Title for the All Tools screen
      ),
    );
  }
}
