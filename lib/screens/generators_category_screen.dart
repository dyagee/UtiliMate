// lib/screens/generators_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart';

class GeneratorsCategoryScreen extends StatelessWidget {
  const GeneratorsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final generatorTools = AppConstants.getGeneratorsTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Generators',
        helpContentKey: 'GENERATORS_CATEGORY', // Will add this help content
      ),
      body: ToolGrid(tools: generatorTools, title: 'Available Generators'),
    );
  }
}
