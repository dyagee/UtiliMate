// lib/widgets/tool_grid.dart
import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart'; // Ensure ToolItem is imported
import 'package:utilimate/widgets/tool_card.dart'; // FIX: Import ToolCard

class ToolGrid extends StatelessWidget {
  final List<ToolItem> tools;
  final Function(ToolItem)? onToolTap; // Optional callback for tapping a tool
  final String? title; // Optional title for the grid itself

  const ToolGrid({super.key, required this.tools, this.onToolTap, this.title});

  @override
  Widget build(BuildContext context) {
    // Variable to detect when in landscape
    var screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding:
                screenSize.width > screenSize.height
                    ? EdgeInsets.symmetric(vertical: 16.00, horizontal: 78.00)
                    : EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  screenSize.width > screenSize.height
                      ? 4
                      : 2, // Adjust as needed for your layout
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0, // Adjust if cards are not square
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return ToolCard(
                // FIX: Use the ToolCard widget
                tool: tool,
                onTap: () {
                  if (onToolTap != null) {
                    onToolTap!(tool);
                  } else {
                    // Default navigation if no custom callback is provided
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: tool.screenBuilder),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
