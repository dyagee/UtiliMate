// lib/widgets/tool_card.dart
import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';

class ToolCard extends StatelessWidget {
  final ToolItem tool;
  final VoidCallback onTap;

  const ToolCard({super.key, required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribute space
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                tool.icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              // Increased flex to give more space to the text
              Expanded(
                flex: 3, // Give more flex to the text
                child: Align(
                  // Align text to center vertically within its expanded space
                  alignment: Alignment.center,
                  child: Text(
                    tool.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize:
                          12, // Slightly increased font size for readability
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4, // Allow up to 3 lines for the name
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Reduced flex for the tag to ensure it takes minimal space
              Expanded(
                flex: 1, // Give less flex to the tag
                child: Align(
                  alignment: Alignment.bottomCenter, // Align tag to bottom
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color:
                          tool.type == ToolType.offline
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tool.type == ToolType.offline ? 'Offline' : 'Online',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            tool.type == ToolType.offline
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
