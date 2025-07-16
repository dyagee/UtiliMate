// lib/widgets/tool_grid.dart
import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';
import 'package:utilimate/widgets/tool_card.dart';

class ToolGrid extends StatelessWidget {
  final List<ToolItem> tools;
  final String? title; // Optional title for the grid/category

  const ToolGrid({super.key, required this.tools, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 8.0,
            ),
            child: Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Changed to 3 items per row
              crossAxisSpacing: 12.0, // Reduced spacing slightly
              mainAxisSpacing: 12.0, // Reduced spacing slightly
              childAspectRatio:
                  0.75, // Adjusted for better fit with 3 items and smaller content
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return ToolCard(
                tool: tool,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => tool.screen),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
