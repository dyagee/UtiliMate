import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';
import 'package:utilimate/services/connectivity_service.dart'; // Import the service
import 'package:utilimate/widgets/message_box.dart'; // Import the custom message box

class ToolCard extends StatelessWidget {
  final ToolItem tool;
  final VoidCallback onTap;

  const ToolCard({super.key, required this.tool, required this.onTap});

  // Helper to show custom message box
  Future<void> _showMessageBox(
    BuildContext context,
    String title,
    String message, {
    bool isError = false,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MessageBox(
          title: title,
          message: message,
          isError: isError,
          onOk: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Variable to detect landscape
    var screenSize = MediaQuery.of(context).size;
    // Use LayoutBuilder to get the parent's constraints (e.g., the size of the Card).
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calculate dynamic icon and font sizes based on the card's width.
        // This makes the content scale proportionally with the card itself.
        final double cardWidth = constraints.maxWidth;
        final double iconSize = cardWidth * 0.2;
        final double fontSize = cardWidth * 0.09;

        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () async {
              // Get the singleton instance of ConnectivityService
              final connectivityService = ConnectivityService();

              // Check connectivity ONLY if the tool is an online tool
              if (tool.type == ToolType.online) {
                final isConnected = connectivityService.isConnected;
                if (!isConnected) {
                  // If offline, show error message and DO NOT call the parent's onTap
                  await _showMessageBox(
                    context, // Pass context to the helper function
                    'No Internet Connection',
                    'This is an online tool and requires an active internet connection. Please connect to the internet to use it. 🌐',
                    isError: true,
                  );
                  return; // Prevent further execution of the onTap callback
                }
              }
              // If the tool is offline, OR if it's online and there IS connectivity,
              // then proceed to call the onTap callback provided by the parent.
              onTap();
            },
            child: Padding(
              padding:
                  screenSize.width > screenSize.height
                      ? EdgeInsets.all(24)
                      : EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Use the calculated icon size
                  Icon(
                    tool.icon,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  // Use Flexible to allow the text to shrink or grow
                  Flexible(
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Text(
                          tool.name,
                          textAlign: TextAlign.center,
                          // Use the calculated font size
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize,
                          ),
                          overflow: TextOverflow.visible,
                          maxLines: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Use a Flexible widget for the status container to allow it to shrink if needed
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color:
                              tool.type == ToolType.offline
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tool.type == ToolType.offline ? 'Offline' : 'Online',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                fontSize * 0.7, // Status label text is smaller
                            color:
                                tool.type == ToolType.offline
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800,
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
      },
    );
  }
}
