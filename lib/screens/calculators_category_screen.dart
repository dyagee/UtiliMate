// lib/screens/calculators_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart';

class CalculatorsCategoryScreen extends StatelessWidget {
  const CalculatorsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculatorTools = AppConstants.getCalculatorTools();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Calculators',
        helpContentKey: 'CALCULATORS_CATEGORY', // Will add this help content
      ),
      body: ToolGrid(tools: calculatorTools, title: 'Available Calculators'),
    );
  }
}
