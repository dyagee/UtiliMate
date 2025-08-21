// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/models/tool_item.dart'; // Ensure ToolItem is imported
import 'package:utilimate/widgets/tool_card.dart'; // FIX: Import ToolCard

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Example: A simple list of tools for demonstration
  final List<ToolItem> _displayTools = AppConstants.allTools;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UtiliMate')),
      body: GridView.builder(
        // Or ListView.builder, depending on your layout
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust as needed
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: _displayTools.length,
        itemBuilder: (context, index) {
          final tool = _displayTools[index];
          return ToolCard(
            // FIX: Use the ToolCard widget here
            tool: tool,
            onTap: () {
              // Navigation logic remains the same, but now it's inside ToolCard's onTap
              Navigator.push(
                context,
                MaterialPageRoute(builder: tool.screenBuilder),
              );
            },
          );
        },
      ),
    );
  }
}
